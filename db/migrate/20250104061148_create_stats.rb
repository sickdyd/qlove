class CreateStats < ActiveRecord::Migration[7.2]
  def change
    create_table :player_stats do |t|
      t.references :player, null: false, foreign_key: true
      t.boolean :aborted, default: false
      t.integer :blue_flag_pickups, default: 0
      t.integer :damage_dealt, default: 0
      t.integer :damage_taken, default: 0
      t.integer :deaths, default: 0
      t.integer :holy_shits, default: 0
      t.integer :kills, default: 0
      t.integer :lose, default: 0
      t.string :match_guid, null: false
      t.integer :max_streak, default: 0
      t.integer :neutral_flag_pickups, default: 0
      t.integer :play_time, default: 0
      t.boolean :quit, default: false
      t.integer :rank, default: 0
      t.integer :red_flag_pickups, default: 0
      t.integer :score, default: 0
      t.integer :team, default: 0
      t.integer :team_join_time, default: 0
      t.integer :team_rank, default: 0
      t.integer :tied_rank, default: 0
      t.integer :tied_team_rank, default: 0
      t.boolean :warmup, default: false
      t.boolean :win, default: false

      t.timestamps
    end
  end
end
