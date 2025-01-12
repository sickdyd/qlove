class CreateDamageCalculatorWeeks < ActiveRecord::Migration[7.2]
  def change
    create_view :damage_calculator_weeks, materialized: true

    add_index :damage_calculator_weeks, :total_damage_dealt
    add_index :damage_calculator_weeks, :total_damage_taken
    add_index :damage_calculator_weeks, :player_id, unique: true
  end
end
