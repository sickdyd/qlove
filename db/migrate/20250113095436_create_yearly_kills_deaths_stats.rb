class CreateYearlyKillsDeathsStats < ActiveRecord::Migration[7.2]
  def change
    create_view :yearly_kills_deaths_stats, materialized: true
    add_index :yearly_kills_deaths_stats, :player_id, unique: true
    add_index :yearly_kills_deaths_stats, :steam_id, unique: true
  end
end
