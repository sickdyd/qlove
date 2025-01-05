module TimeFilterable
  extend ActiveSupport::Concern

  VALID_TIMEZONES = ActiveSupport::TimeZone.all.map(&:name).freeze
  DEFAULT_TIMEZONE = 'Beijing'.freeze

  TIME_FILTERS = {
    day: 'day',
    week: 'week',
    month: 'month'
  }.freeze

  def self.start_time_for(time_filter:, timezone:)
    unless TIME_FILTERS.values.include?(time_filter) && VALID_TIMEZONES.include?(timezone)
      raise ArgumentError, 'Invalid time_filter or timezone'
    end

    case time_filter
    when TIME_FILTERS[:day]
      Time.current.in_time_zone(timezone).beginning_of_day
    when TIME_FILTERS[:week]
      Time.current.in_time_zone(timezone).beginning_of_week
    when TIME_FILTERS[:month]
      Time.current.in_time_zone(timezone).beginning_of_month
    else
      nil
    end
  end
end
