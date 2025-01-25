class BaseMaterializedView < ApplicationRecord
  self.abstract_class = true

  def self.readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end

  def self.all_time(timezone:, limit:, sort_by:, medals: nil)
    query = all

    # Call the block to allow the derived class to modify the query
    # This is used for medals and weapons filtering
    query = yield(query) if block_given?

    query
      .order("#{sort_by} DESC")
      .limit(limit)
  end

  private

  def self.to_table(data:, headers:, time_filter:, sort_by:)
    title = table_title(time_filter: time_filter, sort_by: sort_by)
    TabletizeService.new(title: title, data: data, headers: headers).table
  end

  def self.table_title(time_filter:, sort_by:)
    time_filter == "all_time" ? "All Time #{sort_by.titleize}" : "#{sort_by.titleize} for the #{time_filter}"
  end
end
