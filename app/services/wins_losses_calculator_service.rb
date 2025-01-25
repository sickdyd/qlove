class WinsLossesCalculatorService < BaseCalculatorService
  private

  def model
    WinsLossesStat
  end

  def time_filter_results
    query = Stat.where("stats.created_at >= ?", start_time)

    results = query.joins(:player)
      .select(
        "players.name as player_name",
        "players.steam_id as steam_id",
        "SUM(stats.win) as total_wins",
        "SUM(stats.lose) as total_losses"
      )
      .group("players.id", "players.name", "players.steam_id")
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
  end
end
