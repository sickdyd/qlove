class KillsDeathsStats < BaseMaterializedView
  TOTAL_KILLS_COLUMN = 'total_kills'.freeze
  TOTAL_DEATHS_COLUMN = 'total_deaths'.freeze
  KILL_DEATH_RATIO_COLUMN = 'kills_deaths_ratio'.freeze
  HEADERS = %w[player_name total_damage_dealt total_damage_taken].freeze

  # Dynamically associate the model with the table aligned with the time filter
  TIME_FILTER_TO_TABLE = {
    'all_time' => 'all_time_kills_deaths_stats',
    'year' => 'yearly_kills_deaths_stats',
    'month' => 'monthly_kills_deaths_stats',
    'week' => 'weekly_kills_deaths_stats',
    'day' => 'daily_kills_deaths_stats'
  }.freeze

  def self.for_time_range(time_filter)
    table_name = TIME_FILTER_TO_TABLE[time_filter]
    raise ArgumentError, "Invalid time filter: #{time_filter}" unless table_name

    self.table_name = table_name
    self
  end

  def self.kills_and_deaths(time_filter:, timezone:, limit:, formatted_table:, year:, sort_by:)
    validate_year(time_filter: time_filter, year: year)

    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    query = for_time_range(time_filter).order("#{sort_by} DESC").limit(limit)

    # Yearly stats can be filtered by year
    if time_filter == 'year'
      query = query.where(year: year)
    end

    data = query.to_a

    return formatted_table ? to_table(data: data, headers: HEADERS, time_filter: time_filter, sort_by: sort_by) : data
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error("Error in #{self.class}: #{e.message}")
    raise
  end
end
