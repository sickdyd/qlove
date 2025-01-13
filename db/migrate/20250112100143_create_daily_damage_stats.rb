class CreateDailyDamageStats < ActiveRecord::Migration[7.2]
  def change
    create_view :daily_damage_stats, materialized: true
    add_index :daily_damage_stats, :steam_id, unique: true
    add_index :daily_damage_stats, :player_id, unique: true
  end
end
