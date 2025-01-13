class AccuracyCalculatorService
  include TimeFilterable

  UNAVAILABLE_ACCURACY = '-'

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

  SHORTENED_WEAPON_NAMES = {
    'bfg' => 'BFG',
    'chaingun' => 'CG',
    'gauntlet' => 'G',
    'grenade' => 'GL',
    'hmg' => 'HMG',
    'lightning' => 'LG',
    'machinegun' => 'MG',
    'nailgun' => 'NG',
    'other_weapon' => 'OW',
    'plasma' => 'PG',
    'proxmine' => 'PM',
    'railgun' => 'RG',
    'rocket' => 'RL',
    'shotgun' => 'SG'
  }.freeze

  SHORTENED_HEADERS = {
    average_accuracy: 'AVG'
  }

  def self.calculate_accuracy(time_filter:, timezone:, limit:, formatted_table:, year:, weapons:, steam_id: nil)
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    return [] unless start_time.present?

    begin
      query = Weapon.joins(stat: :player)
      query = query.where('player.steam_id = ?', steam_id) if steam_id.present?
      query = query.where(name: weapons)
      query = query.where('stats.created_at >= ?', start_time)

      all_weapon_damages = query.group('player.id', 'weapons.name')
        .pluck('player.steam_id', 'player.name', 'weapons.name', 'SUM(weapons.shots) as total_shots', 'SUM(weapons.hits) as total_hits')

      results = all_weapon_damages.inject({}) do |hash, (steam_id, player_name, weapon_name, total_shots, total_hits)|
        key = {
          steam_id: steam_id,
          player_name: player_name
        }

        hash[key] ||= { weapons: [], total_accuracy: 0, valid_weapon_count: 0 }

        weapon_accuracy = total_shots.to_i.zero? ? UNAVAILABLE_ACCURACY : (total_hits.to_f / total_shots.to_f * 100).round

        hash[key][:weapons] << {
          weapon_name: SHORTENED_WEAPON_NAMES[weapon_name],
          accuracy: weapon_accuracy
        }

        if weapon_accuracy != UNAVAILABLE_ACCURACY
          hash[key][:total_accuracy] += weapon_accuracy
          hash[key][:valid_weapon_count] += 1
        end

        hash
      end

      final_results = results.map do |key, value|
        average_accuracy = value[:valid_weapon_count].positive? ? (value[:total_accuracy] / value[:valid_weapon_count]).round : UNAVAILABLE_ACCURACY

        weapon_stats = value[:weapons].each_with_object({}) do |weapon, hash|
          hash[weapon[:weapon_name].to_sym] = weapon[:accuracy]
        end

        average_accuracy_key = SHORTENED_HEADERS[:average_accuracy]
        key.merge(average_accuracy_key => average_accuracy).merge(weapon_stats)
      end

      sorted_results = final_results.sort_by do |key, _value|
        key[:average_accuracy] == "-" ? -Float::INFINITY : key[:average_accuracy]
      end.reverse.take(limit)

      formatted_table ? to_table(data: sorted_results, time_filter: time_filter, weapons: weapons) : sorted_results
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Error in AccuracyCalculatorService: #{e.message}")
      []
    end
  end

  private

  def self.to_table(data:, time_filter:, weapons:)
    title = "Best Accuracy for the #{time_filter}"
    headers = %w[player_name avg].concat(weapons.map { |weapon| SHORTENED_WEAPON_NAMES[weapon] })
    TabletizeService.new(title: title, data: data, headers: headers).table
  end
end
