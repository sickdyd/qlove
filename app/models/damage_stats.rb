class DamageStats < BaseMaterializedView
  self.abstract_class = true

  TOTAL_DAMAGE_DEALT_COLUMN = 'total_damage_dealt'.freeze
  TOTAL_DAMAGE_TAKEN_COLUMN = 'total_damage_taken'.freeze
  HEADERS = %w[player_name total_damage_dealt total_damage_taken].freeze

  def self.for_time_filter(time_filter)
    time_filter_class ={
      'all_time' => DamageStats::AllTimeDamageStats,
      'year' => DamageStats::YearlyDamageStats,
      'month' => DamageStats::MonthlyDamageStats,
      'week' => DamageStats::WeeklyDamageStats,
      'day' => DamageStats::DailyDamageStats
    }[time_filter]

    raise ArgumentError, "Invalid time filter: #{time_filter}" unless time_filter_class

    time_filter_class
  end

  def self.leaderboard(time_filter:, timezone:, limit:, sort_by:, formatted_table:, year:)
    validate_year(time_filter: time_filter, year: year)

    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    query = order("#{sort_by} DESC").limit(limit)

    # Yearly stats can be filtered by year
    if time_filter == 'year'
      query = query.where(year: year)
    end

    data = query.to_a

    formatted_table ? format_table(data: data, headers: HEADERS, time_filter: time_filter, sort_by: sort_by) : data
  end
end
