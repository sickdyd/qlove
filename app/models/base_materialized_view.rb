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
end
