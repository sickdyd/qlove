class WinLoseCalculatorService
  include TimeFilterable

  TOTAL_WINS_COLUMN = 'total_wins'.freeze
  TOTAL_LOSSES_COLUMN = 'total_losses'.freeze

  def self.wins(params)
    calculate_win_and_lose(**params.merge(sort_by: TOTAL_WINS_COLUMN))
  end

  def self.losses(params)
    calculate_win_and_lose(**params.merge(sort_by: TOTAL_LOSSES_COLUMN))
  end

  private

  def self.calculate_win_and_lose(time_filter:, timezone:, limit:, sort_by:, formatted_table:, year:)
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

      final_results = results.map do |result|
        {
          steam_id: result.steam_id,
          player_name: result.player_name,
          total_wins: result.total_wins.to_i,
          total_losses: result.total_losses.to_i
        }
      end

      formatted_table ? formatted_table(data: final_results, time_filter: time_filter, sort_by: sort_by) : final_results
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Error in WinLoseCalculatorService: #{e.message}")
      []
    end
  end

  def self.formatted_table(data:, time_filter:, sort_by:)
    title = "#{sort_by.titleize} for the #{time_filter}"
    headers = %w[player_name total_wins total_losses]
    TabletizeService.new(title: title, data: data, headers: headers).table
  end
end
