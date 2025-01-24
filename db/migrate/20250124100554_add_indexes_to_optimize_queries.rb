class AddIndexesToOptimizeQueries < ActiveRecord::Migration[6.0]
  def change
    add_index :weapons, :name
    add_index :stats, :created_at
    add_index :stats, [:created_at, :player_id]
  end
end
