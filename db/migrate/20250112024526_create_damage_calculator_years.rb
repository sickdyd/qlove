class CreateDamageCalculatorYears < ActiveRecord::Migration[7.2]
  def change
    create_view :damage_calculator_years, materialized: true

    add_index :damage_calculator_years, :total_damage_dealt
    add_index :damage_calculator_years, :total_damage_taken
    add_index :damage_calculator_years, :player_id, unique: true
  end
end
