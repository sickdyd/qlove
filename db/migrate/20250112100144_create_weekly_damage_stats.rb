class CreateWeeklyDamageStats < ActiveRecord::Migration[7.2]
  def change
    create_view :weekly_damage_stats, materialized: true
    add_index :weekly_damage_stats, :steam_id, unique: true
    add_index :weekly_damage_stats, :player_id, unique: true
  end
end
