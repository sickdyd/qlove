module EventHandlers
  BOT_STEAM_ID = "0"

  class PlayerConnectHandler
    def self.handle(event_data)
      return unless EventHandlers::Validator.valid?(event_data: event_data)

      Rails.logger.debug "Handling PLAYER_CONNECT event: #{event_data}"

      steam_id = event_data.dig("DATA", "STEAM_ID")
      name = event_data.dig("DATA", "NAME")

      create_or_update_player(steam_id: steam_id, name: name)
    end

    def self.create_or_update_player(steam_id:, name:)
      return if steam_id.blank?

      updated_steam_id = steam_id == BOT_STEAM_ID ? bot_steam_id(name) : steam_id

      player = Player.find_or_create_by!(steam_id: updated_steam_id)
      player.update!(name: name.presence || "UnnamedPlayer")

      player
    end

    # Converts the bot name to a unique ID for bots
    def self.bot_steam_id(name)
      Digest::MD5.hexdigest(name)
    end
  end
end
