class CreateDamageCalculatorDays < ActiveRecord::Migration[7.2]
  def change
    create_view :damage_calculator_days, materialized: true

    add_index :damage_calculator_days, :total_damage_dealt
    add_index :damage_calculator_days, :total_damage_taken
    add_index :damage_calculator_days, :player_id, unique: true
  end
end
