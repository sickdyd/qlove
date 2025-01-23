class BaseMaterializedView < ApplicationRecord
  self.abstract_class = true

  def self.readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end

  def self.model_for_time_filter(time_filter)
    # Reconstruct the name of the class based on the time filter, such as DamageStat::DailyDamageStat
    "#{name}::#{TimeFilterable::TIME_FILTER_TO_ADJECTIVE[time_filter].camelize}#{name}".constantize
  end

  def self.leaderboard(time_filter:, timezone:, limit:, sort_by:, formatted_table:, medals: nil)
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)
    end_time = Time.current.in_time_zone(timezone)

    query = all

    # Call the block to allow the derived class to modify the query
    # This is used for medals and weapons filtering
    query = yield(query) if block_given?

    data = query
      .where(created_at: start_time..end_time)
      .order("#{sort_by} DESC")
      .limit(limit)

    if formatted_table
      headers = model_for_time_filter(time_filter)::HEADERS
      return to_table(data: data, headers: headers, time_filter: time_filter, sort_by: sort_by)
    end

    data
  end

  private

  def self.to_table(data:, headers:, time_filter:, sort_by:)
    title = "#{sort_by.titleize} for the #{time_filter}"
    TabletizeService.new(title: title, data: data, headers: headers).table
  end
end
