module EventHandlers
  class PlayerConnectHandler
    def self.handle(event_data)
      return unless EventHandlers::MainHandler.valid?(event_data: event_data)

      Rails.logger.info "Handling PLAYER_CONNECT event: #{event_data}"

      player = Player.find_or_create_by(steam_id: event_data['STEAM_ID'])
      player.update(name: event_data['NAME'])
    end
  end
end
