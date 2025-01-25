require "test_helper"

class AccuracyCalculatorServiceTest < ActiveSupport::TestCase
  setup do
    player1 = create(:player, steam_id: "STEAM_1", name: "Player One")
    player2 = create(:player, steam_id: "STEAM_2", name: "Player Two")
    player3 = create(:player, steam_id: "STEAM_3", name: "Player Three")
    player4 = create(:player, steam_id: "STEAM_4", name: "Player Four")
    player5 = create(:player, steam_id: "STEAM_5", name: "Player Five")

    @current_time = Date.new(2024, 12, 20)

    travel_to @current_time do
      stat1 = create(:stat, player: player1, created_at: Time.current)
      stat2 = create(:stat, player: player2, created_at: 3.day.ago)
      stat3 = create(:stat, player: player1, created_at: 2.day.ago)
      stat4 = create(:stat, player: player3, created_at: Time.current)
      stat5 = create(:stat, player: player4, created_at: 2.week.ago)
      stat6 = create(:stat, player: player5, created_at: 2.month.ago)

      create(:weapon, stat: stat1, name: "rocket", shots: 100, hits: 50)
      create(:weapon, stat: stat1, name: "shotgun", shots: 100, hits: 50)
      create(:weapon, stat: stat1, name: "railgun", shots: 100, hits: 50)

      create(:weapon, stat: stat2, name: "rocket", shots: 100, hits: 70)
      create(:weapon, stat: stat2, name: "shotgun", shots: 100, hits: 70)
      create(:weapon, stat: stat2, name: "railgun", shots: 100, hits: 70)

      create(:weapon, stat: stat3, name: "rocket", shots: 100, hits: 20)
      create(:weapon, stat: stat3, name: "shotgun", shots: 100, hits: 20)
      create(:weapon, stat: stat3, name: "railgun", shots: 100, hits: 20)

      create(:weapon, stat: stat4, name: "rocket", shots: 100, hits: 10)
      create(:weapon, stat: stat4, name: "shotgun", shots: 100, hits: 10)
      create(:weapon, stat: stat4, name: "railgun", shots: 100, hits: 10)

      create(:weapon, stat: stat5, name: "rocket", shots: 100, hits: 80)
      create(:weapon, stat: stat5, name: "shotgun", shots: 100, hits: 80)
      create(:weapon, stat: stat5, name: "railgun", shots: 100, hits: 80)

      create(:weapon, stat: stat6, name: "rocket", shots: 100, hits: 90)
      create(:weapon, stat: stat6, name: "shotgun", shots: 100, hits: 90)
      create(:weapon, stat: stat6, name: "railgun", shots: 100, hits: 90)
    end

    AccuracyStat.refresh
  end

  teardown do
    travel_back
  end

  test "#time_filter_results returns the correct data" do
    travel_to @current_time do
      service = AccuracyCalculatorService.new(**accuracy_caulculator_service_default_params)
      results = service.leaderboard

      assert_equal 2, results.size
      assert_equal "STEAM_1", results.first[:steam_id]
      assert_equal 50, results.first[AccuracyStat::SHORTENED_HEADERS[:average_accuracy].to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is week" do
    travel_to @current_time do
      service = AccuracyCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "week"))
      results = service.leaderboard

      assert_equal 3, results.size
      assert_equal "STEAM_2", results.first[:steam_id]
      assert_equal 70, results.first[AccuracyStat::SHORTENED_HEADERS[:average_accuracy].to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is month" do
    travel_to @current_time do
      service = AccuracyCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "month"))
      results = service.leaderboard

      assert_equal 4, results.size
      assert_equal "STEAM_4", results.first[:steam_id]
      assert_equal 80, results.first[AccuracyStat::SHORTENED_HEADERS[:average_accuracy].to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is year" do
    travel_to @current_time do
      service = AccuracyCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "year"))
      results = service.leaderboard

      assert_equal 5, results.size
      assert_equal "STEAM_5", results.first[:steam_id]
      assert_equal 90, results.first[AccuracyStat::SHORTENED_HEADERS[:average_accuracy].to_sym]
    end
  end

  def accuracy_caulculator_service_default_params
    {
      time_filter: "day",
      timezone: "UTC",
      limit: 10,
      formatted_table: false,
      sort_by: "average_accuracy",
      weapons: ["rocket", "shotgun", "railgun"]
    }
  end
end
