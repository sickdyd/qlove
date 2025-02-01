class MedalsCalculatorService < BaseCalculatorService
  TOTAL_MEDALS_COLUMN = "total"

  attr_reader :time_filter, :timezone, :limit, :formatted_table, :weapons, :medals, :steam_id, :sort_by

  def initialize(time_filter: "day", timezone: "UTC", limit: 10, formatted_table: false, weapons: WeaponValidatable::ALL_WEAPONS, medals: ALL_MEDALS, steam_id: nil, sort_by: "created_at")
    @time_filter = time_filter
    @timezone = timezone
    @limit = limit
    @formatted_table = formatted_table
    @weapons = weapons
    @steam_id = steam_id
    @sort_by = sort_by
    @medals = medals
  end

  def leaderboard
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

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

    formatted_table ? to_table(headers: headers, data: data, title: table_title) : data
  end

  private

  def headers
    [ "name", "total" ] + medals
  end

  def medals_sql
    medals.map do |medal|
      "SUM(stats.#{medal}) FILTER (WHERE stats.#{medal} IS NOT NULL) AS #{medal}"
    end.join(", ")
  end

  def total_medals_sql
    medals_filter = medals.map { |medal| "stats.#{medal} IS NOT NULL" }.join(" OR ")
    medals_sum = medals.map { |medal| "stats.#{medal}" }.join(" + ")

    "SUM(#{medals_sum}) FILTER (WHERE #{medals_filter}) AS total"
  end

  def table_title
    "Most medals for the #{time_filter}"
  end

  def to_table(headers:, data:, title:)
    TabletizeService.new(headers: headers, data: data, title: title).table
  end
end
