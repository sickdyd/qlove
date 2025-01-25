require "test_helper"

class WinsLossesCalculatorTest < ActiveSupport::TestCase
  setup do
    player1 = create(:player, steam_id: "STEAM_1", name: "Player One")
    player2 = create(:player, steam_id: "STEAM_2", name: "Player Two")
    player3 = create(:player, steam_id: "STEAM_3", name: "Player Three")
    player4 = create(:player, steam_id: "STEAM_4", name: "Player Four")
    player5 = create(:player, steam_id: "STEAM_5", name: "Player Five")

    @current_time = Date.new(2024, 12, 20)

    travel_to @current_time do
      create(:stat, player: player1, win: 1, lose: 0, created_at: Time.current)
      create(:stat, player: player1, win: 1, lose: 0, created_at: Time.current)
      create(:stat, player: player1, win: 1, lose: 0, created_at: 2.day.ago)

      create(:stat, player: player2, win: 0, lose: 1, created_at: 3.day.ago)
      create(:stat, player: player2, win: 0, lose: 1, created_at: Time.current)
      create(:stat, player: player3, win: 1, lose: 0, created_at: Time.current)
      create(:stat, player: player4, win: 0, lose: 1, created_at: 2.week.ago)
      create(:stat, player: player5, win: 1, lose: 0, created_at: 2.month.ago)
    end

    AccuracyStat.refresh
  end

  teardown do
    travel_back
  end

  test "#time_filter_results returns the correct data when time_filter is day when sorted by #{WinsLossesStat::TOTAL_WINS_COLUMN}" do
    travel_to @current_time do
      service = WinsLossesCalculatorService.new(**accuracy_caulculator_service_default_params)
      results = service.leaderboard

      assert_equal 3, results.size
      assert_equal "STEAM_1", results.first[:steam_id]
      assert_equal 2, results.first[WinsLossesStat::TOTAL_WINS_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is week when sorted by #{WinsLossesStat::TOTAL_WINS_COLUMN}" do
    travel_to @current_time do
      service = WinsLossesCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "week"))
      results = service.leaderboard

      assert_equal 3, results.size
      assert_equal "STEAM_1", results.first[:steam_id]
      assert_equal 3, results.first[WinsLossesStat::TOTAL_WINS_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is month when sorted by #{WinsLossesStat::TOTAL_WINS_COLUMN}" do
    travel_to @current_time do
      service = WinsLossesCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "month"))
      results = service.leaderboard

      assert_equal 4, results.size
      assert_equal "STEAM_1", results.first[:steam_id]
      assert_equal 3, results.first[WinsLossesStat::TOTAL_WINS_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is year when sorted by #{WinsLossesStat::TOTAL_WINS_COLUMN}" do
    travel_to @current_time do
      service = WinsLossesCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "year"))
      results = service.leaderboard

      assert_equal 5, results.size
      assert_equal "STEAM_1", results.first[:steam_id]
      assert_equal 3, results.first[WinsLossesStat::TOTAL_WINS_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is day when sorted by #{WinsLossesStat::TOTAL_LOSSES_COLUMN}" do
    travel_to @current_time do
      service = WinsLossesCalculatorService.new(**accuracy_caulculator_service_default_params.merge(sort_by: WinsLossesStat::TOTAL_LOSSES_COLUMN))
      results = service.leaderboard

      assert_equal 3, results.size
      assert_equal "STEAM_2", results.first[:steam_id]
      assert_equal 1, results.first[WinsLossesStat::TOTAL_LOSSES_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is week when sorted by #{WinsLossesStat::TOTAL_LOSSES_COLUMN}" do
    travel_to @current_time do
      service = WinsLossesCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "week", sort_by: WinsLossesStat::TOTAL_LOSSES_COLUMN))
      results = service.leaderboard

      assert_equal 3, results.size
      assert_equal "STEAM_2", results.first[:steam_id]
      assert_equal 2, results.first[WinsLossesStat::TOTAL_LOSSES_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is month when sorted by #{WinsLossesStat::TOTAL_LOSSES_COLUMN}" do
    travel_to @current_time do
      service = WinsLossesCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "month", sort_by: WinsLossesStat::TOTAL_LOSSES_COLUMN))
      results = service.leaderboard

      assert_equal 4, results.size
      assert_equal "STEAM_2", results.first[:steam_id]
      assert_equal 2, results.first[WinsLossesStat::TOTAL_LOSSES_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is year when sorted by #{WinsLossesStat::TOTAL_LOSSES_COLUMN}" do
    travel_to @current_time do
      service = WinsLossesCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "year", sort_by: WinsLossesStat::TOTAL_LOSSES_COLUMN))
      results = service.leaderboard

      assert_equal 5, results.size
      assert_equal "STEAM_2", results.first[:steam_id]
      assert_equal 2, results.first[WinsLossesStat::TOTAL_LOSSES_COLUMN.to_sym]
    end
  end

  def accuracy_caulculator_service_default_params
    {
      time_filter: "day",
      timezone: "UTC",
      limit: 10,
      formatted_table: false,
      sort_by: WinsLossesStat::TOTAL_WINS_COLUMN,
    }
  end
end
