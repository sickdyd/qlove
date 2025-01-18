require "test_helper"

class DailyDamageStatsTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    create_list(:stat, 10, created_at: Time.zone.now.beginning_of_day)
    create(:stat, damage_dealt: 110000)
    create(:stat, damage_taken: 130000)
    @old_stats = create_list(:stat, 2, created_at: Time.zone.now - 2.days)

    DamageStats::DailyDamageStats.refresh
  end

  test "model_for_time_filter returns the correct class" do
    assert_equal DamageStats::DailyDamageStats, DamageStats.model_for_time_filter("day")
  end

  test "leaderboard returns today's stats sorted by total_damage_dealt" do
    results = DamageStats::DailyDamageStats.leaderboard(
      time_filter: "day",
      timezone: "UTC",
      limit: 5,
      sort_by: DamageStats::TOTAL_DAMAGE_DEALT_COLUMN,
      formatted_table: false,
      year: nil
    )

    assert_equal 5, results.count
    assert_equal 110000, results.first.total_damage_dealt
  end

  test "leaderboard returns today's stats sorted by total_damage_taken" do
    results = DamageStats::DailyDamageStats.leaderboard(
      time_filter: "day",
      timezone: "UTC",
      limit: 5,
      sort_by: DamageStats::TOTAL_DAMAGE_TAKEN_COLUMN,
      formatted_table: false,
      year: nil
    )

    assert_equal 5, results.count
    assert_equal 130000, results.first.total_damage_taken
  end

  test "leaderboard does not include stats from other days" do
    results = DamageStats::DailyDamageStats.leaderboard(
      time_filter: "day",
      timezone: "UTC",
      limit: 10,
      sort_by: DamageStats::TOTAL_DAMAGE_DEALT_COLUMN,
      formatted_table: false,
      year: nil
    )

    assert_not_includes results.map(&:id), @old_stats.map(&:id)
   end
end
