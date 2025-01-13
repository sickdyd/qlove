class CreateYearlyDamageStats < ActiveRecord::Migration[7.2]
  def change
    create_view :yearly_damage_stats, materialized: true
    add_index :yearly_damage_stats, [:steam_id, :year], unique: true
    add_index :yearly_damage_stats, [:player_id, :year], unique: true
  end
end
