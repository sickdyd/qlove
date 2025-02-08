class CreateAllTimeDamageStats < ActiveRecord::Migration[8.0]
  def change
    create_view :all_time_damage_stats, materialized: true
    add_index :all_time_damage_stats, :steam_id, unique: true
    add_index :all_time_damage_stats, :id, unique: true
  end
end
