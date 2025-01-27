class BaseCalculatorService
  attr_reader :time_filter, :timezone, :limit, :formatted_table, :weapons, :steam_id, :sort_by

  def initialize(time_filter: "day", timezone: "UTC", limit: 10, formatted_table: false, weapons: WeaponValidatable::ALL_WEAPONS, steam_id: nil, sort_by: "created_at")
    @time_filter = time_filter
    @timezone = timezone
    @limit = limit
    @formatted_table = formatted_table
    @weapons = weapons
    @steam_id = steam_id
    @sort_by = sort_by
  end

  def leaderboard
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    query = Stat.joins(:player)

    unless block_given?
      raise NotImplementedError, "You must add the select statement to the leaderboard method of the subclass"
    end

    query = yield(query)

    data = query
      .where("stats.created_at >= ?", start_time)
      .group("players.id, players.steam_id, players.name")
      .order("#{sort_by} DESC")
      .limit(limit)

    formatted_table ? to_table(headers: headers, data: data, title: table_title) : data
  end

  private

  def to_table(headers:, data:, title:)
    TabletizeService.new(headers: headers, data: data, title: title).table
  end
end
