class BestPlayersCalculatorService < BaseCalculatorService
  HEADERS = %w[ name average_accuracy total_damage_dealt total_kills strength]
  # The sort by value is generated programmatically
  SORT_BY_COLUMN = "strength".freeze

  def leaderboard
    default_params = Api::V1::BaseController::COMMON_PARAMS_DEFAULTS.merge(limit: Player.count, time_filter: time_filter)
    accuracies_params = default_params.merge(sort_by: AccuracyCalculatorService::AVERAGE_ACCURACY_COLUMN, weapons: WeaponValidatable::ALL_WEAPONS)
    damage_params = default_params.merge(sort_by: DamageCalculatorService::TOTAL_DAMAGE_DEALT_COLUMN)
    kills_deaths_params = default_params.merge(sort_by: KillsDeathsCalculatorService::TOTAL_KILLS_COLUMN)

    all_time_accuracies = AccuracyCalculatorService.new(**accuracies_params).leaderboard
    all_time_damage_dealt = DamageCalculatorService.new(**damage_params).leaderboard
    all_time_kills_deaths = KillsDeathsCalculatorService.new(**kills_deaths_params).leaderboard

    return [] unless all_time_accuracies.present? && all_time_damage_dealt.present? && all_time_kills_deaths.present?

    max_accuracy = all_time_accuracies.first.avg
    max_damage = all_time_damage_dealt.first.total_damage_dealt
    max_kills = all_time_kills_deaths.first.total_kills

    unsorted_data = Player.all.map do |player|
      # TODO: fix "find_by(player: player)" failing miserably
      accuracy = all_time_accuracies.find { |acc| acc.player.id == player.id }
      damage = all_time_damage_dealt.find { |dmg| dmg.player.id == player.id }
      kills_deaths = all_time_kills_deaths.find { |kd| kd.player.id == player.id }

      next nil unless accuracy.present? && damage.present? && kills_deaths.present?

      avg_acc = accuracy[:avg]
      dmg = damage[:total_damage_dealt]
      kills = kills_deaths[:total_kills]

      {
        name: player.name,
        average_accuracy: avg_acc,
        total_damage_dealt: dmg,
        total_kills: kills,
        strength: calculate_strength(avg_acc, dmg, kills, max_accuracy, max_damage, max_kills)
      }
    end.compact

    sorted_data = unsorted_data
      .sort_by { |player| -player[SORT_BY_COLUMN.to_sym] }
      .first(limit.to_i)

    data = sorted_data.map { |player| OpenStruct.new(player) }

    handle_query_results(data)
  end

  private

  # Returns a normalized value between 0 and 100 representing the strenght of a player
  def calculate_strength(accuracy, damage_dealt, kills, max_accuracy, max_damage, max_kills)
    normalized_accuracy = accuracy.to_f / max_accuracy
    normalized_damage_dealt = damage_dealt.to_f / max_damage
    normalized_kills = kills.to_f / max_kills

    raw_strength = normalized_accuracy + normalized_damage_dealt + normalized_kills

    (raw_strength / 3 * 100).round
  end
end
