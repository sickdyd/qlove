class CreateStats < ActiveRecord::Migration[7.2]
  def change
    create_table :stats do |t|
      t.references :player, null: false, foreign_key: true

      # Match Data
      t.string :match_guid, null: false
      t.integer :deaths, default: 0
      t.integer :kills, default: 0
      t.integer :lose, default: 0
      t.integer :play_time, default: 0
      t.integer :quit, default: 0
      t.integer :rank, default: 0
      t.integer :score, default: 0
      t.integer :win, default: 0
      t.integer :damage_dealt, default: 0
      t.integer :damage_taken, default: 0

      # Medals Data
      t.integer :accuracy, default: 0
      t.integer :assists, default: 0
      t.integer :captures, default: 0
      t.integer :combokill, default: 0
      t.integer :defends, default: 0
      t.integer :excellent, default: 0
      t.integer :firstfrag, default: 0
      t.integer :headshot, default: 0
      t.integer :humiliation, default: 0
      t.integer :impressive, default: 0
      t.integer :midair, default: 0
      t.integer :perfect, default: 0
      t.integer :perforated, default: 0
      t.integer :quadgod, default: 0
      t.integer :rampage, default: 0
      t.integer :revenge, default: 0

      # Weapons Data
      t.integer :bfg_accuracy, default: 0
      t.integer :bfg_time, default: 0

      t.integer :cg_accuracy, default: 0
      t.integer :cg_time, default: 0

      t.integer :g_accuracy, default: 0
      t.integer :g_time, default: 0

      t.integer :gl_accuracy, default: 0
      t.integer :gl_time, default: 0

      t.integer :hmg_accuracy, default: 0
      t.integer :hmg_time, default: 0

      t.integer :lg_accuracy, default: 0
      t.integer :lg_time, default: 0

      t.integer :mg_accuracy, default: 0
      t.integer :mg_time, default: 0

      t.integer :ng_accuracy, default: 0
      t.integer :ng_time, default: 0

      t.integer :ow_accuracy, default: 0
      t.integer :ow_time, default: 0

      t.integer :pg_accuracy, default: 0
      t.integer :pg_time, default: 0

      t.integer :pm_accuracy, default: 0
      t.integer :pm_time, default: 0

      t.integer :rg_accuracy, default: 0
      t.integer :rg_time, default: 0

      t.integer :rl_accuracy, default: 0
      t.integer :rl_time, default: 0

      t.integer :sg_accuracy, default: 0
      t.integer :sg_time, default: 0

      t.integer :game_average_accuracy, default: 0

      t.timestamps
    end

    add_index :stats, :created_at
  end
end
