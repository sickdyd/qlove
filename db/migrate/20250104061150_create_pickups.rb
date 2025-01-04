class CreatePickups < ActiveRecord::Migration[7.2]
  def change
    create_table :pickups do |t|
      t.references :player_stat, null: false, foreign_key: true
      t.integer :ammo, default: 0
      t.integer :armor, default: 0
      t.integer :armor_regen, default: 0
      t.integer :battlesuit, default: 0
      t.integer :doubler, default: 0
      t.integer :flight, default: 0
      t.integer :green_armor, default: 0
      t.integer :guard, default: 0
      t.integer :haste, default: 0
      t.integer :health, default: 0
      t.integer :invis, default: 0
      t.integer :invulnerability, default: 0
      t.integer :kamikaze, default: 0
      t.integer :medkit, default: 0
      t.integer :mega_health, default: 0
      t.integer :other_holdable, default: 0
      t.integer :other_powerup, default: 0
      t.integer :portal, default: 0
      t.integer :quad, default: 0
      t.integer :red_armor, default: 0
      t.integer :regen, default: 0
      t.integer :scout, default: 0
      t.integer :teleporter, default: 0
      t.integer :yellow_armor, default: 0

      t.timestamps
    end
  end
end
