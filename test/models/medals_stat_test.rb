require "test_helper"

class MedalsStatTest < ActiveSupport::TestCase
  setup do
    player = create(:player)

    stat1 = create(:stat, player: player)
    stat2 = create(:stat, player: player)
    stat3 = create(:stat, player: player)

    medals1 = create(:medal, stat: stat1)
    medals2 = create(:medal, stat: stat2)
    medals3 = create(:medal, stat: stat3)

    create(:medal)

    @total_medals = 0

    MedalsStat::ALL_MEDALS.each do |medal|
      @total_medals += medals1.send(medal.to_sym)
      @total_medals += medals2.send(medal.to_sym)
      @total_medals += medals3.send(medal.to_sym)
    end

    MedalsStat.refresh
  end

  test "returns all materialized view columns correctly" do
    results = MedalsStat.all_time(
      timezone: "UTC",
      limit: MedalsStat::ALL_MEDALS.count,
      sort_by: "player_id",
      medals: MedalsStat::ALL_MEDALS
    )

    assert_equal 2, results.count
    assert_equal %w[player_id player_name steam_id] + MedalsStat::ALL_MEDALS + [ "total_medals" ], results.first.attributes.keys
  end

  test "returns all time stats sorted by total_medals" do
    results = MedalsStat.all_time(
      timezone: "UTC",
      limit: 1,
      sort_by: MedalsStat::TOTAL_MEDALS_COLUMN,
      medals: MedalsStat::ALL_MEDALS
    )

    assert_equal 1, results.count
    assert_equal @total_medals, results.first.total_medals
  end

  test "returns only specific medals stats" do
    medals = %w[accuracy assists captures]
    results = MedalsStat.all_time(
      timezone: "UTC",
      limit: 1,
      sort_by: MedalsStat::TOTAL_MEDALS_COLUMN,
      medals: medals
    )

    expected_keys = %w[player_id player_name steam_id] + medals + [ "total_medals" ]

    assert_equal 1, results.count
    assert_equal expected_keys, results.first.attributes.keys
  end
end
