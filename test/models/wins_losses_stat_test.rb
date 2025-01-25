require "test_helper"

STAT_COUNT = 183

class WinsLossesStatTest < ActiveSupport::TestCase
  setup do
    create_list(:stat, 20, created_at: Time.zone.now.beginning_of_day)
    player1 = create(:player, name: "VOX AC10")
    player2 = create(:player, name: "^7D^1r^7a^1g^7o^1n")
    STAT_COUNT.times do
      create(:stat, player: player1, win: 1, lose: 0)
      create(:stat, player: player2, win: 0, lose: 1)
    end
    @old_stats = create_list(:stat, 15, created_at: Faker::Time.between_dates(from: 2.year.ago, to: 1.week.ago, period: :all))

    WinsLossesStat.refresh
  end

  test "returns all time stats sorted by total_wins" do
    results = WinsLossesStat.all_time(
      timezone: "UTC",
      limit: 5,
      sort_by: WinsLossesStat::TOTAL_WINS_COLUMN,
    )

    assert_equal 5, results.count
    assert_equal STAT_COUNT, results.first.total_wins
    assert_equal "VOX AC10", results.first.player_name
  end

  test "returns all time stats sorted by total_losses" do
    results = WinsLossesStat.all_time(
      timezone: "UTC",
      limit: 5,
      sort_by: WinsLossesStat::TOTAL_LOSSES_COLUMN,
    )

    assert_equal 5, results.count
    assert_equal STAT_COUNT, results.first.total_losses
    assert_equal "^7D^1r^7a^1g^7o^1n", results.first.player_name
  end

  test "returns all stats" do
    results = WinsLossesStat.all_time(
      timezone: "UTC",
      # arbitrary limit
      limit: 100,
      sort_by: WinsLossesStat::TOTAL_WINS_COLUMN,
    )

    # even if we create many more stats, the materialized view will
    # compact them into a single row per player
    assert_equal 37, results.count
    @old_stats.each do |stat|
      assert results.map(&:player_id).include?(stat.player_id)
    end
   end
end
