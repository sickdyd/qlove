module EventHandlers
  class PlayerConnectHandler
    def self.handle(event_data)
      return unless EventHandlers::MainHandler.valid?(event_data: event_data)

      Rails.logger.debug "Handling PLAYER_CONNECT event: #{event_data}"

      steam_id = event_data.dig('DATA', 'STEAM_ID')
      name = event_data.dig('DATA', 'NAME')

      create_player(steam_id: steam_id, name: name)
    end

    def self.create_player(steam_id:, name:)
      return if steam_id.blank? || name.blank?

      player = Player.find_or_create_by(steam_id: steam_id)
      player.update!(name: name)

      player
    end
  end
end
