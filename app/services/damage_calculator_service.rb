class DamageCalculatorService
  include TimeFilterable

  TOTAL_DAMAGE_DEALT_COLUMN = 'total_damage_dealt'.freeze
  TOTAL_DAMAGE_TAKEN_COLUMN = 'total_damage_taken'.freeze

  def self.damage_dealt(params)
    calculate_damage(**params.merge(sort_by: TOTAL_DAMAGE_DEALT_COLUMN))
  end

  def self.damage_taken(params)
    calculate_damage(**params.merge(sort_by: TOTAL_DAMAGE_TAKEN_COLUMN))
  end

  private

  def self.calculate_damage(time_filter:, timezone:, limit:, formatted_table:, sort_by:)
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    return [] unless start_time.present?

    begin
      query = Stat.where('stats.created_at >= ?', start_time)

      results = query.joins(:player)
        .select(
          'players.name as player_name',
          'players.steam_id as steam_id',
          'SUM(stats.damage_dealt) as total_damage_dealt',
          'SUM(stats.damage_taken) as total_damage_taken'
        )
        .group('players.id', 'players.name', 'players.steam_id')
        .order("#{sort_by} DESC")
        .limit(limit)

      final_results = results.map do |result|
        {
          steam_id: result.steam_id,
          player_name: result.player_name,
          total_damage_dealt: result.total_damage_dealt.to_i,
          total_damage_taken: result.total_damage_taken.to_i
        }
      end

      return formatted_table ? formatted_table(data: final_results, time_filter: time_filter, sort_by: sort_by) : results
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Error in DamageCalculatorService: #{e.message}")
      []
    end
  end

  def self.formatted_table(data:, time_filter:, sort_by:)
    title = "#{sort_by.titleize} for the #{time_filter}"
    headers = %w[player_name total_damage_dealt total_damage_taken]
    TabletizeService.new(title: title, data: data, headers: headers).table
  end
end
