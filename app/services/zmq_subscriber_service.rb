require "ffi-rzmq"

class ZmqSubscriberService
  EVENT_HANDLER_MAP = {
    "PLAYER_CONNECT" => EventHandlers::PlayerConnectHandler,
    "PLAYER_STATS" => EventHandlers::PlayerStatsHandler,
    "MATCH_REPORT" => EventHandlers::RefreshMaterializedViewsHandler
  }.freeze

  def self.run
    zmq_subscriber = ZmqSubscriber.first
    return unless zmq_subscriber
    return if zmq_subscriber.started?

    Rails.logger.info "Starting ZMQ Subscriber for #{zmq_subscriber.host}:#{zmq_subscriber.port}..."

    Thread.new do
      begin
        context = ZMQ::Context.new
        subscriber = context.socket(ZMQ::SUB)

        subscriber.setsockopt(ZMQ::PLAIN_USERNAME, zmq_subscriber.username)
        subscriber.setsockopt(ZMQ::PLAIN_PASSWORD, zmq_subscriber.password)

        zmq_url = "tcp://#{zmq_subscriber.host}:#{zmq_subscriber.port}"
        subscriber.connect(zmq_url)
        subscriber.setsockopt(ZMQ::SUBSCRIBE, "")

        Rails.logger.info "Connected to ZeroMQ at #{zmq_url}, listening for all events."

        zmq_subscriber.update!(started: true)

        at_exit do
          Rails.logger.info "ZMQ Subscriber shutting down..."
          zmq_subscriber.update!(started: false)
          subscriber&.close
          context&.terminate
        end

        loop do
          message = ""
          subscriber.recv_string(message)
          if message.strip.empty?
            Rails.logger.warn "ZMQ received empty message, skipping..."
            next
          end
          event_data = JSON.parse(message)

          event_type = event_data["TYPE"]
          handler_class = EVENT_HANDLER_MAP[event_type]

          if handler_class.blank?
            Rails.logger.debug "No handler for event type: #{event_type}, ignoring."
          else
            handler_class.handle(event_data)
          end
        end
      rescue Interrupt
        Rails.logger.info "ZMQ Subscriber interrupted."
      rescue StandardError => e
        Rails.logger.error "Error in ZMQ Subscriber: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
      ensure
        zmq_subscriber.update!(started: false)
        Rails.logger.info "Shutting down ZMQ Subscriber..."
        subscriber&.close
        context&.terminate
      end
    end
  end
end
