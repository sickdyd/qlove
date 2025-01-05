class KillDeathCalculatorService
  include TimeFilterable

  def self.kills(time_filter:, timezone:, limit:)
    calculate_kills_and_deaths(time_filter: time_filter, timezone: timezone, limit: limit, sort_by: 'total_kills')
  end

  def self.deaths(time_filter:, timezone:, limit:)
    calculate_kills_and_deaths(time_filter: time_filter, timezone: timezone, limit: limit, sort_by: 'total_deaths')
  end

  private

  def self.calculate_kills_and_deaths(time_filter:, timezone:, limit:, sort_by:)
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    return [] unless start_time.present?

    begin
      query = Stat.where('stats.created_at >= ?', start_time)

      results = query.joins(:player)
                     .select(
                       'players.name as player_name',
                       'players.steam_id as steam_id',
                       'SUM(stats.kills) as total_kills',
                       'SUM(stats.deaths) as total_deaths'
                     )
                     .group('players.id', 'players.name', 'players.steam_id')
                     .order("#{sort_by} DESC")
                     .limit(limit)

      results.map do |result|
        {
          steam_id: result.steam_id,
          player_name: result.player_name,
          total_kills: result.total_kills.to_i,
          total_deaths: result.total_deaths.to_i,
          kill_death_ratio: result.total_deaths.to_i.zero? ? result.total_kills.to_i : (result.total_kills.to_f / result.total_deaths.to_f).round(2)
        }
      end
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Error in KillDeathCalculatorService: #{e.message}")
      []
    end
  end
end
