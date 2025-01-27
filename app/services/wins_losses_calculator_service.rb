class WinsLossesCalculatorService < BaseCalculatorService
  TOTAL_WINS_COLUMN = "total_wins"
  TOTAL_LOSSES_COLUMN = "total_losses"

  def leaderboard
    super do |query|
      query
        .select("
          players.id,
          players.steam_id,
          players.name,
          SUM(stats.win) as total_wins,
          SUM(stats.lose) as total_losses
        ")
    end
  end
end
