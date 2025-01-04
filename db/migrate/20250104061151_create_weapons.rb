class CreateWeapons < ActiveRecord::Migration[7.2]
  def change
    create_table :weapons do |t|
      t.references :player_stat, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :deaths, default: 0
      t.integer :damage_given, default: 0
      t.integer :damage_received, default: 0
      t.integer :hits, default: 0
      t.integer :kills, default: 0
      t.integer :pickups, default: 0
      t.integer :shots, default: 0
      t.integer :time, default: 0

      t.timestamps
    end
  end
end
