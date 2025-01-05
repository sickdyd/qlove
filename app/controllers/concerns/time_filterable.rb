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
