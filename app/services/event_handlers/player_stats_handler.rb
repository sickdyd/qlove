module EventHandlers
  class PlayerStatsHandler
    def self.handle(event_data)
      return unless EventHandlers::Validator.valid?(event_data: event_data, filters: { "WARMUP" => false, "ABORTED" => false, "QUIT" => 1 })
      return if event_data["DATA"]["QUIT"].to_i == 1

      Rails.logger.debug "Handling PLAYER_STATS event: #{event_data}"

      data = event_data["DATA"]
      steam_id = data.dig("STEAM_ID")
      player_name = data.dig("NAME")

      player = EventHandlers::PlayerConnectHandler.create_or_update_player(steam_id: steam_id, name: player_name)

      stat_data = match_data(data)
        .merge(medals_data(data["MEDALS"]))
        .merge(weapons_data(data["WEAPONS"]))
        .merge(player: player)

      stat = Stat.create!(stat_data)

      Rails.logger.debug "PLAYER_STATS event processed successfully for player: #{player.name} (#{player.steam_id})"
    rescue StandardError => e
      Rails.logger.error "Failed to process PLAYER_STATS event: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end

    private

    def self.match_data(data)
      {
        match_guid: data["MATCH_GUID"],
        deaths: data["DEATHS"],
        kills: data["KILLS"],
        lose: data["LOSE"],
        play_time: data["PLAY_TIME"],
        quit: data["QUIT"],
        rank: data["RANK"],
        score: data["SCORE"],
        win: data["WIN"],
        damage_dealt: data.dig("DAMAGE", "DEALT"),
        damage_taken: data.dig("DAMAGE", "TAKEN")
      }
    end

    def self.medals_data(data)
      {
        accuracy: data["ACCURACY"],
        assists: data["ASSISTS"],
        captures: data["CAPTURES"],
        combokill: data["COMBOKILL"],
        defends: data["DEFENDS"],
        excellent: data["EXCELLENT"],
        firstfrag: data["FIRSTFRAG"],
        headshot: data["HEADSHOT"],
        humiliation: data["HUMILIATION"],
        impressive: data["IMPRESSIVE"],
        midair: data["MIDAIR"],
        perfect: data["PERFECT"],
        perforated: data["PERFORATED"],
        quadgod: data["QUADGOD"],
        rampage: data["RAMPAGE"],
        revenge: data["REVENGE"]
      }
    end

    def self.weapons_data(data)
      results = {}
      total_accuracies = []

      data.each do |name, stats|
        weapon_key = WeaponValidatable::SHORTENED_WEAPON_NAMES[name.downcase].downcase
        weapon_accuracy = accuracy(shots: stats["S"].to_i, hits: stats["H"].to_i)
        total_accuracies << weapon_accuracy unless weapon_accuracy == nil

        results["#{weapon_key}_accuracy"] = weapon_accuracy
        results["#{weapon_key}_time"] = stats["T"].to_i
      end

      game_average_accuracy = total_accuracies.size > 0 ? (total_accuracies.sum.to_f / total_accuracies.size).round(0) : nil

      results.merge(game_average_accuracy: game_average_accuracy)
    end

    def self.accuracy(shots:, hits:)
      return nil if shots.zero?

      (hits.to_f / shots * 100).round(0)
    end
  end
end
