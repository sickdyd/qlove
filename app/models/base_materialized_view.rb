class BaseMaterializedView < ApplicationRecord
  self.abstract_class = true
  self.primary_key = :player_id

  scope :for_year, ->(year) { for_time_range('year').where(year: year) }
  scope :for_all_time, -> { for_time_range('all_time') }
  scope :for_this_month, -> { for_time_range('month') }
  scope :for_this_week, -> { for_time_range('week') }
  scope :for_today, -> { for_time_range('day') }

  def self.readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end

  def self.for_time_filter(time_filter)
    # Reconstruct the name of the class based on the time filter, such as DamageStats::DailyDamageStats
    "#{name}::#{TimeFilterable::TIME_FILTER_TO_ADJECTIVE[time_filter].camelize}#{name}".camelize.constantize
  end

  private

  def self.validate_year(time_filter:, year:)
    return if time_filter != 'year'
    return if year.present? && year.to_i.positive?

    raise ArgumentError, 'Year must be a positive integer'
  end

  def self.start_time(time_filter:, timezone:)
    TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)
  end

  def self.to_table(data:, headers:, time_filter:, sort_by:)
    title = "#{sort_by.titleize} for the #{time_filter}"
    TabletizeService.new(title: title, data: data, headers: headers).table
  end
end
