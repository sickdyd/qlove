class CreateAllTimeMedalsStats < ActiveRecord::Migration[7.2]
  def change
    create_view :all_time_medals_stats, materialized: true
    add_index :all_time_medals_stats, :steam_id, unique: true
    add_index :all_time_medals_stats, :player_id, unique: true
  end
end
