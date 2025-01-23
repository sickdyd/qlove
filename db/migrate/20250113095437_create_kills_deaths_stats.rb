class CreateKillsDeathsStats < ActiveRecord::Migration[7.2]
  def change
    create_view :kills_deaths_stats, materialized: true
    add_index :kills_deaths_stats, :player_id, unique: true
    add_index :kills_deaths_stats, :steam_id, unique: true
  end
end
