class AccuracyCalculatorService
  include TimeFilterable

  def self.weapon_accuracies_for_all_players(time_filter: TimeFilterable::TIME_FILTERS[:day], timezone: TimeFilterable::DEFAULT_TIMEZONE)
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    return [] unless start_time

    query = Weapon.joins(stat: :player)
    query = query.where('stats.created_at >= ?', start_time) if start_time

    query.group('players.id', 'players.steam_id', 'players.name', :name)
         .pluck('players.steam_id', 'players.name', :name, 'SUM(shots) as total_shots', 'SUM(hits) as total_hits')
         .group_by { |steam_id, _, _, _, _| steam_id }
         .map do |steam_id, weapon_stats|
           weapons_data = weapon_stats.each_with_object({}) do |(_, _, weapon_name, total_shots, total_hits), weapons_hash|
             accuracy = total_shots.to_i.zero? ? "-" : (total_hits.to_f / total_shots.to_f * 100).round
             weapons_hash[weapon_name] = accuracy
           end

           used_weapon_accuracies = weapons_data.values.reject { |accuracy| accuracy == "-" }
           average_accuracy = if used_weapon_accuracies.empty?
                                "-"
                              else
                                (used_weapon_accuracies.sum.to_f / used_weapon_accuracies.size).round
                              end

           {
             steam_id: steam_id,
             name: weapon_stats.first[1],
             average_accuracy: average_accuracy,
             weapons: weapons_data
           }
         end
  end
end
