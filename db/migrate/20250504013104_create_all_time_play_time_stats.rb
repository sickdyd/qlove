class CreateAllTimePlayTimeStats < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    create_view :all_time_play_time_stats, materialized: true

    add_index :all_time_play_time_stats, :steam_id, unique: true, algorithm: :concurrently
    add_index :all_time_play_time_stats, :player_id, unique: true, algorithm: :concurrently
  end
end
