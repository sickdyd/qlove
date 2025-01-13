class CreateWeeklyKillsDeathsStats < ActiveRecord::Migration[7.2]
  def change
    create_view :weekly_kills_deaths_stats, materialized: true
    add_index :weekly_kills_deaths_stats, :player_id, unique: true
    add_index :weekly_kills_deaths_stats, :steam_id, unique: true
  end
end
