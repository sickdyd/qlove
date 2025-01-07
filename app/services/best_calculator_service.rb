class BestCalculatorService
  include TimeFilterable

  def self.best_players(time_filter:, timezone:, limit:)
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)
    return [] unless start_time.present?

    stats = Stat.where('stats.created_at >= ?', start_time).includes(:player, :weapons)

    player_totals = stats.each_with_object({}) do |stat, totals|
      player = stat.player
      player_id = player.id

      totals[player_id] ||= {
        steam_id: player.steam_id,
        player_name: player.name,
        total_kills: 0,
        total_damage_given: 0,
        total_game_accuracies: 0.0,
        total_games: 0
      }

      totals[player_id][:total_kills] += stat.kills
      totals[player_id][:total_damage_given] += stat.damage_dealt

      # Calculate game-level average_accuracy
      game_accuracies = stat.weapons.map do |weapon|
        next if weapon.shots.zero?
        weapon.hits.to_f / weapon.shots * 100
      end.compact

      if game_accuracies.any?
        game_avg_accuracy = game_accuracies.sum / game_accuracies.size
        totals[player_id][:total_game_accuracies] += game_avg_accuracy
        totals[player_id][:total_games] += 1
      end
    end

    calculate_scores(player_totals, limit)
  end

  private

  def self.calculate_scores(player_totals, limit)
    player_totals.values.map do |player_data|
      average_accuracy = if player_data[:total_games] > 0
                           (player_data[:total_game_accuracies] / player_data[:total_games]).round
                         else
                           0
                         end

      kills = player_data[:total_kills]
      damage_given = player_data[:total_damage_given]

      final_score = (average_accuracy + (damage_given / 1000.0) * 0.5 + kills * 0.3).round

      {
        steam_id: player_data[:steam_id],
        player_name: player_data[:player_name],
        average_accuracy: average_accuracy,
        final_score: final_score,
        total_damage_given: damage_given,
        total_kills: kills,
        total_games: player_data[:total_games]
      }
    end.sort_by { |player| -player[:final_score] }.first(limit)
  end
end
