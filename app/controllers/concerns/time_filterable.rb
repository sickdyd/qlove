module TimeFilterable
  extend ActiveSupport::Concern

  VALID_TIMEZONES = ActiveSupport::TimeZone.all.map(&:name).freeze
  DEFAULT_TIMEZONE = 'Beijing'.freeze

  TIME_FILTERS = %w[day week month year all_time].freeze

  TIME_FILTER_TO_TABLE_SUFFIX = {
    'day' => 'days',
    'week' => 'weeks',
    'month' => 'months',
    'year' => 'years',
    'all_time' => 'all_times'
  }

  def self.start_time_for(time_filter:, timezone:)
    unless TIME_FILTERS.include?(time_filter)
      raise ArgumentError, invalid_time_filter_error_message
    end

    unless VALID_TIMEZONES.include?(timezone)
      raise ArgumentError, invalid_timezone_error_message
    end

    case time_filter
    when 'day'
      Time.current.in_time_zone(timezone).beginning_of_day
    when 'week'
      Time.current.in_time_zone(timezone).beginning_of_week
    when 'month'
      Time.current.in_time_zone(timezone).beginning_of_month
    when 'year'
      Time.current.in_time_zone(timezone).beginning_of_year
    when 'all_time'
      Time.new(ValidateCommonParams::EARLIEST_YEAR)
    end
  end

  def self.invalid_time_filter_error_message
    "Invalid time_filter, must be one of #{TIME_FILTERS.join(", ")}"
  end

  def self.invalid_timezone_error_message
    "Invalid timezone, must be one of #{VALID_TIMEZONES.join(", ")}"
  end
end
