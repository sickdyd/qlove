class DamageCalculatorService
  include TimeFilterable

  def self.damage_dealt(time_filter:, timezone:, limit:)
    calculate_damage(time_filter: time_filter, timezone: timezone, limit: limit, sort_by: 'total_damage_dealt')
  end

  def self.damage_received(time_filter:, timezone:, limit:)
    calculate_damage(time_filter: time_filter, timezone: timezone, limit: limit, sort_by: 'total_damage_taken')
  end

  private

  def self.calculate_damage(time_filter:, timezone:, limit:, sort_by:)
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

      results.map do |result|
        {
          steam_id: result.steam_id,
          player_name: result.player_name,
          total_damage_dealt: result.total_damage_dealt.to_i,
          total_damage_taken: result.total_damage_taken.to_i
        }
      end
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Error in DamageCalculatorService: #{e.message}")
      []
    end
  end
end
