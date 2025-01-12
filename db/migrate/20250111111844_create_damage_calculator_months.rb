class CreateDamageCalculatorMonths < ActiveRecord::Migration[7.2]
  def change
    create_view :damage_calculator_months, materialized: true

    add_index :damage_calculator_months, :total_damage_dealt
    add_index :damage_calculator_months, :total_damage_taken
    add_index :damage_calculator_months, :player_id, unique: true
  end
end
