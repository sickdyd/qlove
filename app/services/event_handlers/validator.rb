module EventHandlers
  class Validator
    def self.valid?(event_data:, filters: {})

      if event_data['DATA'].blank?
        Rails.logger.debug "Event data is blank, ignoring."
        return false
      end

      filters.each do |key, value|
        unless event_data['DATA'][key] == value
          Rails.logger.debug "Ignoring event because #{key} does not match: #{value}"
          return false
        end
      end

      true
    end
  end
end
