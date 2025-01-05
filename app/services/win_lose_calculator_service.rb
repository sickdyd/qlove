class WinLoseCalculatorService
  include TimeFilterable

  def self.wins(time_filter:, timezone:, limit:)
    calculate_win_and_lose(time_filter: time_filter, timezone: timezone, limit: limit, sort_by: 'total_wins')
  end

  def self.losses(time_filter:, timezone:, limit:)
    calculate_win_and_lose(time_filter: time_filter, timezone: timezone, limit: limit, sort_by: 'total_losses')
  end

  private

  def self.calculate_win_and_lose(time_filter:, timezone:, limit:, sort_by:)
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    return [] unless start_time.present?

    begin
      query = Stat.where('stats.created_at >= ?', start_time)

      results = query.joins(:player)
                     .select(
                       'players.name as player_name',
                       'players.steam_id as steam_id',
                       'SUM(stats.win) as total_wins',
                       'SUM(stats.lose) as total_losses'
                     )
                     .group('players.id', 'players.name', 'players.steam_id')
                     .order("#{sort_by} DESC")
                     .limit(limit)

      results.map do |result|
        {
          steam_id: result.steam_id,
          player_name: result.player_name,
          total_wins: result.total_wins.to_i,
          total_losses: result.total_losses.to_i
        }
      end
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Error in WinLoseCalculatorService: #{e.message}")
      []
    end
  end
end
