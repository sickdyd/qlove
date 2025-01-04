module EventHandlers
  class MainHandler
    def self.valid?(event_data:, additional_filters: {})

      if event_data['DATA'].blank?
        Rails.logger.warn "Event data is blank, ignoring."
        return false
      end

      additional_filters.each do |key, value|
        unless event_data['DATA'][key] == value
          Rails.logger.info "Ignoring event because #{key} does not match: #{value}"
          return false
        end
      end

      true
    end
  end
end
