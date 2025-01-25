require "test_helper"

class AccuracyStatTest < ActiveSupport::TestCase
  setup do
    stat = create(:stat)
    AccuracyStat::ALL_WEAPONS.each do |weapon|
      create(:weapon, stat: stat, name: weapon)
    end

    AccuracyStat.refresh
  end

  test "returns all materialized view columns correctly" do
    results = AccuracyStat.all_time(
      timezone: "UTC",
      limit: AccuracyStat::ALL_WEAPONS.count,
      sort_by: 'player_id'
    )

    AccuracyStat::ALL_WEAPONS.each do |weapon_name|
      weapon = Weapon.find_by(name: weapon_name)
      result = results.find_by(weapon_name: weapon_name)

      assert_equal weapon.shots, result.total_shots
      assert_equal weapon.hits, result.total_hits
    end

    assert_equal AccuracyStat::ALL_WEAPONS.count, results.count
    assert_equal %w[player_id player_name steam_id weapon_name total_shots total_hits created_at], results.first.attributes.keys
  end
end
