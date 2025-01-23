class CreateWinsLossesStats < ActiveRecord::Migration[7.2]
  def change
    create_view :wins_losses_stats, materialized: true
    add_index :wins_losses_stats, :steam_id, unique: true
    add_index :wins_losses_stats, :player_id, unique: true
  end
end
