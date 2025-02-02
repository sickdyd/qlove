class MedalsCalculatorService < BaseCalculatorService
  TOTAL_MEDALS_COLUMN = "total_medals".freeze

  def leaderboard
    data = Stat.joins(:player)
      .select("
        players.id,
        players.steam_id,
        players.name,
        #{medals_sql},
        #{total_medals_sql}
      ")
      .where("stats.created_at >= ?", start_time)
      .group("players.id, players.steam_id, players.name")
      .order("#{sort_by} DESC")
      .limit(limit)

      handle_query_results(data)
  end

  private

  def headers
    [ "name", TOTAL_MEDALS_COLUMN ] + medals
  end

  def medals_sql
    medals.map do |medal|
      "SUM(stats.#{medal}) FILTER (WHERE stats.#{medal} IS NOT NULL) AS #{medal}"
    end.join(", ")
  end

  def total_medals_sql
    medals_filter = medals.map { |medal| "stats.#{medal} IS NOT NULL" }.join(" OR ")
    medals_sum = medals.map { |medal| "stats.#{medal}" }.join(" + ")

    "SUM(#{medals_sum}) FILTER (WHERE #{medals_filter}) AS #{TOTAL_MEDALS_COLUMN}"
  end
end
