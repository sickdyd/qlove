class CreateAllTimeWinsLossesStats < ActiveRecord::Migration[8.0]
  def change
    create_view :all_time_wins_losses_stats, materialized: true
    add_index :all_time_wins_losses_stats, :steam_id, unique: true
    add_index :all_time_wins_losses_stats, :player_id, unique: true
  end
end
