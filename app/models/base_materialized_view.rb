class BaseMaterializedView < ApplicationRecord
  self.abstract_class = true

  def self.readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end

  def self.all_time(timezone:, limit:, sort_by:, formatted_table:)
    query = all

    # Call the block to allow the derived class to modify the query
    # This is used for medals and weapons filtering
    query = yield(query) if block_given?

    data = query
      .order("#{sort_by} DESC")
      .limit(limit)

    if formatted_table
      return to_table(data: data, headers: HEADERS, time_filter: time_filter, sort_by: sort_by)
    end

    data
  end

  private

  def self.to_table(data:, headers:, time_filter:, sort_by:)
    title = "#{sort_by.titleize} for the #{time_filter}"
    TabletizeService.new(title: title, data: data, headers: headers).table
  end
end
