class CreateYearlyMedalsStats < ActiveRecord::Migration[7.2]
  def change
    create_view :yearly_medals_stats, materialized: true
    add_index :yearly_medals_stats, :steam_id, unique: true
    add_index :yearly_medals_stats, :player_id, unique: true
  end
end
