class CreateMedals < ActiveRecord::Migration[7.2]
  def change
    create_table :medals do |t|
      t.references :stat, null: false, foreign_key: true
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

      t.timestamps
    end
  end
end
