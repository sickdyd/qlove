class CreateAllTimeMedalsStats < ActiveRecord::Migration[8.0]
  def change
    create_view :all_time_medals_stats, materialized: true
    add_index :all_time_medals_stats, :steam_id, unique: true
    add_index :all_time_medals_stats, :id, unique: true
  end
end
