class DamageStats < BaseMaterializedView
  TOTAL_DAMAGE_DEALT_COLUMN = 'total_damage_dealt'.freeze
  TOTAL_DAMAGE_TAKEN_COLUMN = 'total_damage_taken'.freeze
  HEADERS = %w[player_name total_damage_dealt total_damage_taken].freeze

  # Dynamically associate the model with the table aligned with the time filter
  TIME_FILTER_TO_TABLE = {
    'all_time' => 'all_time_damage_stats',
    'year' => 'yearly_damage_stats',
    'month' => 'monthly_damage_stats',
    'week' => 'weekly_damage_stats',
    'day' => 'daily_damage_stats'
  }.freeze

  def self.for_time_range(time_filter)
    table_name = TIME_FILTER_TO_TABLE[time_filter]
    raise ArgumentError, "Invalid time filter: #{time_filter}" unless table_name

    self.table_name = table_name
    self
  end

  def self.leaderboard(time_filter:, timezone:, limit:, sort_by:, formatted_table:, year:)
    validate_year(time_filter: time_filter, year: year)

    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    query = for_time_range(time_filter).order("#{sort_by} DESC").limit(limit)

    # Yearly stats can be filtered by year
    if time_filter == 'year'
      query = query.where(year: year)
    end

    data = query.to_a

    formatted_table ? format_table(data: data, headers: HEADERS, time_filter: time_filter, sort_by: sort_by) : data
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error("Error in #{self.class}: #{e.message}")
    raise
  end
end
