class CreateMonthlyKillsDeathsStats < ActiveRecord::Migration[7.2]
  def change
    create_view :monthly_kills_deaths_stats, materialized: true
    add_index :monthly_kills_deaths_stats, :player_id, unique: true
    add_index :monthly_kills_deaths_stats, :steam_id, unique: true
  end
end
