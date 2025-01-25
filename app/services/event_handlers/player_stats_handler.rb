module EventHandlers
  class PlayerStatsHandler
    def self.handle(event_data)
      return unless EventHandlers::Validator.valid?(event_data: event_data, filters: { "WARMUP" => false, "ABORTED" => false })

      Rails.logger.debug "Handling PLAYER_STATS event: #{event_data}"

      data = event_data["DATA"]
      steam_id = data.dig("STEAM_ID")
      name = data.dig("NAME")
      player = EventHandlers::PlayerConnectHandler.create_or_update_player(steam_id: steam_id, name: name)

      stat = Stat.create!(
        player: player,
        match_guid: data["MATCH_GUID"],
        aborted: data["ABORTED"],
        blue_flag_pickups: data["BLUE_FLAG_PICKUPS"],
        deaths: data["DEATHS"],
        holy_shits: data["HOLY_SHITS"],
        kills: data["KILLS"],
        lose: data["LOSE"],
        max_streak: data["MAX_STREAK"],
        play_time: data["PLAY_TIME"],
        quit: data["QUIT"],
        rank: data["RANK"],
        red_flag_pickups: data["RED_FLAG_PICKUPS"],
        score: data["SCORE"],
        team: data["TEAM"],
        team_join_time: data["TEAM_JOIN_TIME"],
        team_rank: data["TEAM_RANK"],
        tied_rank: data["TIED_RANK"],
        tied_team_rank: data["TIED_TEAM_RANK"],
        warmup: data["WARMUP"],
        win: data["WIN"],
        damage_dealt: data.dig("DAMAGE", "DEALT"),
        damage_taken: data.dig("DAMAGE", "TAKEN")
      )

      if data["MEDALS"]
        medals_data = data["MEDALS"]

        Medal.create!(
          stat: stat,
          accuracy: medals_data["ACCURACY"],
          assists: medals_data["ASSISTS"],
          captures: medals_data["CAPTURES"],
          combokill: medals_data["COMBOKILL"],
          defends: medals_data["DEFENDS"],
          excellent: medals_data["EXCELLENT"],
          firstfrag: medals_data["FIRSTFRAG"],
          headshot: medals_data["HEADSHOT"],
          humiliation: medals_data["HUMILIATION"],
          impressive: medals_data["IMPRESSIVE"],
          midair: medals_data["MIDAIR"],
          perfect: medals_data["PERFECT"],
          perforated: medals_data["PERFORATED"],
          quadgod: medals_data["QUADGOD"],
          rampage: medals_data["RAMPAGE"],
          revenge: medals_data["REVENGE"]
        )
      end

      if data["PICKUPS"] and ENV["ENABLE_PICKUPS"] || false
        pickups_data = data["PICKUPS"]

        Pickup.create!(
          stat: stat,
          ammo: pickups_data["AMMO"],
          armor: pickups_data["ARMOR"],
          armor_regen: pickups_data["ARMOR_REGEN"],
          battlesuit: pickups_data["BATTLESUIT"],
          doubler: pickups_data["DOUBLER"],
          flight: pickups_data["FLIGHT"],
          green_armor: pickups_data["GREEN_ARMOR"],
          guard: pickups_data["GUARD"],
          haste: pickups_data["HASTE"],
          health: pickups_data["HEALTH"],
          invis: pickups_data["INVIS"],
          invulnerability: pickups_data["INVULNERABILITY"],
          kamikaze: pickups_data["KAMIKAZE"],
          medkit: pickups_data["MEDKIT"],
          mega_health: pickups_data["MEGA_HEALTH"],
          other_holdable: pickups_data["OTHER_HOLDABLE"],
          other_powerup: pickups_data["OTHER_POWERUP"],
          portal: pickups_data["PORTAL"],
          quad: pickups_data["QUAD"],
          red_armor: pickups_data["RED_ARMOR"],
          regen: pickups_data["REGEN"],
          scout: pickups_data["SCOUT"],
          teleporter: pickups_data["TELEPORTER"],
          yellow_armor: pickups_data["YELLOW_ARMOR"]
        )
      end

      if data["WEAPONS"]
        data["WEAPONS"].each do |name, stats|
          Weapon.create!(
            stat: stat,
            name: name.downcase,
            deaths: stats["D"],
            damage_given: stats["DG"],
            damage_received: stats["DR"],
            hits: stats["H"],
            kills: stats["K"],
            pickups: stats["P"],
            shots: stats["S"],
            time: stats["T"]
          )
        end
      end

      Rails.logger.debug "PLAYER_STATS event processed successfully for player: #{player.name} (#{player.steam_id})"
    rescue StandardError => e
      Rails.logger.error "Failed to process PLAYER_STATS event: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
