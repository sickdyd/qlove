require "test_helper"

class DamageStatTest < ActiveSupport::TestCase
  setup do
    create_list(:stat, 20, created_at: Time.zone.now.beginning_of_day)
    player1 = create(:player, name: "VOX AC10")
    player2 = create(:player, name: "^7D^1r^7a^1g^7o^1n")
    create(:stat, player: player1, damage_dealt: 110000)
    create(:stat, player: player2, damage_taken: 130000)
    @old_stats = create_list(:stat, 15, created_at: Faker::Time.between_dates(from: 2.year.ago, to: 1.week.ago, period: :all))

    DamageStat.refresh
  end

  test "returns all time stats sorted by total_damage_dealt" do
    results = DamageStat.all_time(
      timezone: "UTC",
      limit: 5,
      sort_by: DamageStat::TOTAL_DAMAGE_DEALT_COLUMN,
    )

    assert_equal 5, results.count
    assert_equal 110000, results.first.total_damage_dealt
    assert_equal "VOX AC10", results.first.player_name
  end

  test "returns all time stats sorted by total_damage_taken" do
    results = DamageStat.all_time(
      timezone: "UTC",
      limit: 5,
      sort_by: DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN,
    )

    assert_equal 5, results.count
    assert_equal 130000, results.first.total_damage_taken
    assert_equal "^7D^1r^7a^1g^7o^1n", results.first.player_name
  end

  test "includes all stats" do
    results = DamageStat.all_time(
      timezone: "UTC",
      limit: 35,
      sort_by: DamageStat::TOTAL_DAMAGE_DEALT_COLUMN,
    )

    assert_not_includes results.map(&:id), @old_stats.map(&:id)
   end
end
