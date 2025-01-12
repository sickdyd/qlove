class CreateDamageCalculatorAllTimes < ActiveRecord::Migration[7.2]
  def change
    create_view :damage_calculator_all_times, materialized: true

    add_index :damage_calculator_all_times, :total_damage_dealt
    add_index :damage_calculator_all_times, :total_damage_taken
    add_index :damage_calculator_all_times, :player_id, unique: true
  end
end
