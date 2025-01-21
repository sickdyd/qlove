class CreateMonthlyMedalsStats < ActiveRecord::Migration[7.2]
  def change
    create_view :monthly_medals_stats, materialized: true
    add_index :monthly_medals_stats, :steam_id, unique: true
    add_index :monthly_medals_stats, :player_id, unique: true
  end
end
