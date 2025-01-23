class CreateDamageStats < ActiveRecord::Migration[7.2]
  def change
    create_view :damage_stats, materialized: true
    add_index :damage_stats, :steam_id, unique: true
    add_index :damage_stats, :player_id, unique: true
  end
end
