#!/usr/bin/env ruby

require_relative '.././config/environment'
require 'fileutils'
require 'json'
require 'ffi-rzmq'

Rails.logger.info 'Starting ZMQ Subscriber...'

ZAP_DOMAIN = ENV['ZAP_DOMAIN']&.b
ZMQ_USERNAME = ENV['ZMQ_USERNAME']&.b
ZMQ_PASSWORD = ENV['ZMQ_PASSWORD']&.b

EVENT_HANDLER_MAP = {
  "PLAYER_CONNECT" => EventHandlers::PlayerConnectHandler,
  "PLAYER_STATS" => EventHandlers::PlayerStatsHandler
}.freeze

begin
  context = ZMQ::Context.new
  subscriber = context.socket(ZMQ::SUB)

  subscriber.setsockopt(ZMQ::PLAIN_USERNAME, ZMQ_USERNAME)
  subscriber.setsockopt(ZMQ::PLAIN_PASSWORD, ZMQ_PASSWORD)

  zmq_url = "tcp://#{ENV['ZMQ_HOST']}:#{ENV['ZMQ_PORT']}"
  subscriber.connect(zmq_url)
  subscriber.setsockopt(ZMQ::SUBSCRIBE, '')

  Rails.logger.info "Connected to ZeroMQ PUB socket at: #{zmq_url}, listening for all events."

  loop do
    message = ''
    subscriber.recv_string(message)
    event_data = JSON.parse(message)

    event_type = event_data['TYPE']
    handler_class = EVENT_HANDLER_MAP[event_type]

    if handler_class.blank?
      Rails.logger.debug "Handler does not exist (event type: #{event_type}), ignoring."
    else
      handler_class.handle(event_data)
    end
  end
rescue Interrupt
  Rails.logger.info 'ZMQ Subscriber interrupted.'
rescue StandardError => e
  Rails.logger.error "Error in ZMQ Subscriber: #{e.message}"
  Rails.logger.error e.backtrace.join("\n")
ensure
  Rails.logger.info 'Shutting down ZMQ Subscriber...'
  subscriber&.close
  context&.terminate
end
