class BestPlayersCalculatorService < BaseCalculatorService
  HEADERS = %w[ name accuracy damage kills time strength]
  # The sort by value is generated programmatically
  SORT_BY_COLUMN = "strength".freeze

  def leaderboard
    default_params = Api::V1::BaseController::COMMON_PARAMS_DEFAULTS.merge(limit: Player.count, time_filter: time_filter)
    accuracies_params = default_params.merge(sort_by: AccuracyCalculatorService::AVERAGE_ACCURACY_COLUMN, weapons: WeaponValidatable::ALL_WEAPONS)
    damage_params = default_params.merge(sort_by: DamageCalculatorService::TOTAL_DAMAGE_DEALT_COLUMN)
    kills_deaths_params = default_params.merge(sort_by: KillsDeathsCalculatorService::TOTAL_KILLS_COLUMN)
    play_time_params = default_params.merge(sort_by: PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN)

    all_accuracies = AccuracyCalculatorService.new(**accuracies_params).leaderboard
    all_damage_dealt = DamageCalculatorService.new(**damage_params).leaderboard
    all_kills_deaths = KillsDeathsCalculatorService.new(**kills_deaths_params).leaderboard
    all_play_time = PlayTimeCalculatorService.new(**play_time_params).leaderboard

    return [] unless all_accuracies.present? && all_damage_dealt.present? && all_kills_deaths.present?

    max_accuracy = all_accuracies.first.avg
    max_damage = all_damage_dealt.first.total_damage_dealt
    max_kills = all_kills_deaths.first.total_kills
    max_play_time = all_play_time.first.total_play_time
    min_play_time = all_play_time.last.total_play_time

    unsorted_data = Player.all.map do |player|
      # TODO: fix "find_by(player: player)" failing miserably
      accuracy = all_accuracies.find { |acc| acc.player.id == player.id }
      damage = all_damage_dealt.find { |dmg| dmg.player.id == player.id }
      kills_deaths = all_kills_deaths.find { |kd| kd.player.id == player.id }
      play_time = all_play_time.find { |pt| pt.player_id == player.id }

      next nil unless accuracy.present? && damage.present? && kills_deaths.present? && play_time.present?

      average_accuracy = accuracy[:avg]
      damage = damage[:total_damage_dealt]
      kills = kills_deaths[:total_kills]
      total_play_time = play_time[:total_play_time]

      {
        steam_id: player.steam_id,
        player_id: player.id,
        name: player.name,
        accuracy: average_accuracy,
        damage: damage,
        kills: kills,
        time: total_play_time,
        strength: calculate_strength(average_accuracy, damage, kills, max_accuracy, max_damage, max_kills, min_play_time, max_play_time)
      }
    end.compact

    data = unsorted_data
      .sort_by { |player| -player[SORT_BY_COLUMN.to_sym] }
      .first(limit.to_i)

    # To allow using dot notation to access the stat properties
    handle_query_results(data.map { |stat| Struct.new(*stat.keys).new(*stat.values) })
  end

  private

  # Returns a normalized value between 0 and 100 representing the strenght of a player
  def calculate_strength(accuracy, damage_dealt, kills, max_accuracy, max_damage, max_kills, min_play_time, max_play_time)
    normalized_accuracy = accuracy.to_f / max_accuracy
    normalized_damage_dealt = damage_dealt.to_f / max_damage
    normalized_kills = kills.to_f / max_kills

    raw_strength = normalized_accuracy + normalized_damage_dealt + normalized_kills

    (raw_strength / 3 * 100).round
  end
end
