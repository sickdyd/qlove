class AccuracyCalculatorService
  include TimeFilterable

  ALL_WEAPONS = %w[
    bfg
    chaingun
    gauntlet
    grenade
    hmg
    lightning
    machinegun
    nailgun
    other_weapon
    plasma
    proxmine
    railgun
    rocket
    shotgun
  ].freeze

  def self.accuracy(time_filter:, timezone:, limit:, steam_id: nil, weapons: ALL_WEAPONS)
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    return [] unless start_time.present?

    begin
      query = Weapon.joins(stat: :player)
      query = query.where('stats.created_at >= ?', start_time)
      query = query.where('players.steam_id = ?', steam_id) if steam_id.present?
      query = query.where(name: weapons)

      results = query.group('players.id', 'players.steam_id', 'players.name', :name)
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

      sorted_results = results.sort_by do |result|
        result[:average_accuracy] == "-" ? Float::INFINITY : -result[:average_accuracy]
      end

      sorted_results.first(limit)
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Error in AccuracyCalculatorService: #{e.message}")
      []
    end
  end
end
