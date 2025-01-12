class BaseMaterializedView < ApplicationRecord
  self.abstract_class = true
  self.primary_key = :player_id

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end
end
