class BestPlayerCalculatorService < BaseCalculatorService
  HEADERS = %w[ name average_accuracy total_damage_dealt total_kills strength]

  def leaderboard
    # We need to extract data for every player for all times in order to finally sort them by strength
    default_params = Api::V1::BaseController::COMMON_PARAMS_DEFAULTS.merge(limit: Player.count, time_filter: "all_time")

    all_time_accuracies = AccuracyCalculatorService.new(**default_params).leaderboard
    all_time_damage_dealt = DamageCalculatorService.new(**default_params.merge(sort_by: DamageCalculatorService::TOTAL_DAMAGE_DEALT_COLUMN)).leaderboard
    all_time_kills_deaths = KillsDeathsCalculatorService.new(**default_params.merge(sort_by: KillsDeathsCalculatorService::TOTAL_KILLS_COLUMN)).leaderboard

    max_accuracy = all_time_accuracies.first.avg
    max_damage = all_time_damage_dealt.first.total_damage_dealt
    max_kills = all_time_kills_deaths.first.total_kills

    data = Player.all.map do |player|
      accuracy = all_time_accuracies.find { |a| a[:steam_id] == player.steam_id }
      damage = all_time_damage_dealt.find { |d| d[:steam_id] == player.steam_id }
      kills_deaths = all_time_kills_deaths.find { |kd| kd[:steam_id] == player.steam_id }

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
    end.sort_by { |player| -player[:strength] }.first(default_params[:limit])
  end

  private

  def calculate_strength(accuracy, damage_dealt, kills, max_accuracy, max_damage, max_kills)
    normalized_accuracy = accuracy.to_f / max_accuracy
    normalized_damage_dealt = damage_dealt.to_f / max_damage
    normalized_kills = kills.to_f / max_kills

    raw_strength = normalized_accuracy + normalized_damage_dealt + normalized_kills

    (raw_strength / 3 * 100).round
  end
end
