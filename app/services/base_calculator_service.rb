class BaseCalculatorService
  attr_reader :time_filter, :timezone, :limit, :formatted_table, :weapons, :steam_id, :sort_by

  def initialize(time_filter: "year", timezone: "UTC", limit: 10, formatted_table: false, weapons: WeaponValidatable::ALL_WEAPONS, steam_id: nil, sort_by: "players.created_at")
    @time_filter = time_filter
    @timezone = timezone
    @limit = limit
    @formatted_table = formatted_table
    @weapons = shortened_weapon_names(weapons)
    @steam_id = steam_id
    @sort_by = sort_by
  end

  def leaderboard
    query = Stat.joins(:player)

    unless block_given?
      raise NotImplementedError, "You must add the select statement to the leaderboard method of the subclass"
    end

    query = yield(query)

    data = query
      .where("stats.created_at >= ?", start_time)
      .group("players.id, players.steam_id, players.name")
      .order("#{sort_by} DESC NULLS LAST")
      .limit(limit)

    handle_query_results(data)
  end

  private

  def handle_query_results(data)
    formatted_table ? to_table(headers: headers, data: data, title: table_title) : data
  end

  def start_time
    TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)
  end

  def to_table(headers:, data:, title:)
    TabletizeService.new(headers: headers, data: data, title: title).table
  end

  def headers
    self.class::HEADERS
  end

  def table_title
    "#{sort_by.titleize} for the #{time_filter}"
  end

  def shortened_weapon_names(weapons)
    weapons.map { |weapon| short_weapon_name(weapon) }
  end

  def short_weapon_name(weapon)
    WeaponValidatable::SHORTENED_WEAPON_NAMES[weapon]
  end
end
