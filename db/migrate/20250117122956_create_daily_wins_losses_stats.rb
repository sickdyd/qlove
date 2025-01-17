class CreateDailyWinsLossesStats < ActiveRecord::Migration[7.2]
  def change
    create_view :daily_wins_losses_stats, materialized: true
    add_index :daily_wins_losses_stats, :steam_id, unique: true
    add_index :daily_wins_losses_stats, :player_id, unique: true
  end
end
