class WinsLossesCalculatorService < BaseCalculatorService
  TOTAL_WINS_COLUMN = "total_wins".freeze
  TOTAL_LOSSES_COLUMN = "total_losses".freeze

  HEADERS = [ "name", TOTAL_WINS_COLUMN, TOTAL_LOSSES_COLUMN ]

  def leaderboard
    super do |query|
      query
        .select("
          players.id as player_id,
          players.steam_id,
          players.name,
          SUM(stats.win) as #{TOTAL_WINS_COLUMN},
          SUM(stats.lose) as #{TOTAL_LOSSES_COLUMN}
        ")
    end
  end

  def all_time
    data = AllTimeWinsLossesStat.all.limit(limit).order("#{sort_by} DESC NULLS LAST")
    handle_query_results(data)
  end
end
