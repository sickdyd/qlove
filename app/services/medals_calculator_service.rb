class MedalsCalculatorService < BaseCalculatorService
  TOTAL_MEDALS_COLUMN = "total_medals".freeze

  def leaderboard
    return all_time if time_filter == "all_time"

    data = Stat.joins(:player)
      .select("
        players.id as player_id,
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

  def all_time
    total_medals_expr = medals.map { |medal| "COALESCE(#{medal}, 0)" }.join(" + ")

    data = AllTimeMedalsStat
      .select("
        id,
        name,
        steam_id,
        #{medals_sql(prefix: "")},
        #{total_medals_sql(prefix: "")}
      ")
      .group("id, steam_id, name")
      .order("#{sort_by} DESC")
      .limit(limit)

    handle_query_results(data)
  end

  private

  def headers
    [ "name", TOTAL_MEDALS_COLUMN ] + medals
  end

  def medals_sql(prefix: "stats.")
    medals.map do |medal|
      "SUM(#{prefix}#{medal}) FILTER (WHERE #{prefix}#{medal} IS NOT NULL) AS #{medal}"
    end.join(", ")
  end

  def total_medals_sql(prefix: "stats.")
    medals_filter = medals.map { |medal| "#{prefix}#{medal} IS NOT NULL" }.join(" OR ")
    medals_sum = medals.map { |medal| "#{prefix}#{medal}" }.join(" + ")

    "SUM(#{medals_sum}) FILTER (WHERE #{medals_filter}) AS #{TOTAL_MEDALS_COLUMN}"
  end
end
