class CreateAccuracyStats < ActiveRecord::Migration[7.2]
  def change
    create_view :accuracy_stats, materialized: true

    add_index :accuracy_stats, :steam_id
    add_index :accuracy_stats, :weapon_name
    add_index :accuracy_stats, :created_at
    add_index :accuracy_stats, [:steam_id, :created_at, :weapon_name], unique: true
  end
end
