require "test_helper"

class KillsDeathsStatTest < ActiveSupport::TestCase
  setup do
    create_list(:stat, 20, created_at: Time.zone.now.beginning_of_day)
    player1 = create(:player, name: "VOX AC10")
    player2 = create(:player, name: "^7D^1r^7a^1g^7o^1n")
    create(:stat, player: player1, kills: 1563, deaths: 1)
    create(:stat, player: player2, deaths: 1234)
    @old_stats = create_list(:stat, 15, created_at: Faker::Time.between_dates(from: 2.year.ago, to: 1.week.ago, period: :all))

    KillsDeathsStat.refresh
  end

  test "returns all time stats sorted by total_kills" do
    results = KillsDeathsStat.all_time(
      timezone: "UTC",
      limit: 5,
      sort_by: KillsDeathsStat::TOTAL_KILLS_COLUMN,
    )

    assert_equal 5, results.count
    assert_equal 1563, results.first.total_kills
    assert_equal "VOX AC10", results.first.player_name
  end

  test "returns all time stats sorted by total_deaths" do
    results = KillsDeathsStat.all_time(
      timezone: "UTC",
      limit: 5,
      sort_by: KillsDeathsStat::TOTAL_DEATHS_COLUMN,
    )

    assert_equal 5, results.count
    assert_equal 1234, results.first.total_deaths
    assert_equal "^7D^1r^7a^1g^7o^1n", results.first.player_name
  end

  test "returns all time stats sorted by kill_death_ratio" do
    results = KillsDeathsStat.all_time(
      timezone: "UTC",
      limit: 37,
      sort_by: KillsDeathsStat::KILL_DEATH_RATIO_COLUMN,
    )

    assert_equal 37, results.count

    # nil values are handled in the calculator service, those are players
    # that never died therefore their ratio is set to the number of kills
    without_nil_ratios = results.reject { |result| result.kills_deaths_ratio.nil? }
    assert_equal 1563, without_nil_ratios.first.kills_deaths_ratio
    assert_equal "VOX AC10", without_nil_ratios.first.player_name
  end

  test "returns all stats" do
    results = KillsDeathsStat.all_time(
      timezone: "UTC",
      limit: 100,
      sort_by: KillsDeathsStat::TOTAL_KILLS_COLUMN,
    )

    assert_equal 37, results.count
    @old_stats.each do |stat|
      assert results.map(&:player_id).include?(stat.player_id)
    end
   end
end
