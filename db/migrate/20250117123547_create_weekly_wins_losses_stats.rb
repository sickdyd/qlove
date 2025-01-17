class CreateWeeklyWinsLossesStats < ActiveRecord::Migration[7.2]
  def change
    create_view :weekly_wins_losses_stats, materialized: true
    add_index :weekly_wins_losses_stats, :steam_id, unique: true
    add_index :weekly_wins_losses_stats, :player_id, unique: true
  end
end
