class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :steam_id
      t.string :name
      t.string :model

      t.timestamps
    end
    add_index :players, :steam_id, unique: true
  end
end
