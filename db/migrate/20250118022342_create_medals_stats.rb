class CreateMedalsStats < ActiveRecord::Migration[7.2]
  def change
    create_view :medals_stats, materialized: true
    add_index :medals_stats, :steam_id, unique: true
    add_index :medals_stats, :player_id, unique: true
  end
end
