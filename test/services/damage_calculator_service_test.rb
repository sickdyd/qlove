require "test_helper"

class DamageCalculatorServiceTest < ActiveSupport::TestCase
  setup do
    player1 = create(:player, steam_id: "STEAM_1", name: "Player One")
    player2 = create(:player, steam_id: "STEAM_2", name: "Player Two")
    player3 = create(:player, steam_id: "STEAM_3", name: "Player Three")
    player4 = create(:player, steam_id: "STEAM_4", name: "Player Four")
    player5 = create(:player, steam_id: "STEAM_5", name: "Player Five")

    @current_time = Date.new(2024, 12, 20)

    travel_to @current_time do
      create(:stat, player: player1, damage_dealt: 2000, damage_taken: 100, created_at: Time.current)
      create(:stat, player: player1, damage_dealt: 2000, damage_taken: 100, created_at: 2.day.ago)

      create(:stat, player: player2, damage_dealt: 1000, damage_taken: 1000, created_at: 3.day.ago)
      create(:stat, player: player3, damage_dealt: 300, damage_taken: 300, created_at: Time.current)
      create(:stat, player: player4, damage_dealt: 15000, damage_taken: 3000, created_at: 2.week.ago)
      create(:stat, player: player5, damage_dealt: 500, damage_taken: 500, created_at: 2.month.ago)
    end

    AccuracyStat.refresh
  end

  teardown do
    travel_back
  end

  test "#time_filter_results returns the correct data when time_filter is day when sorted by #{DamageStat::TOTAL_DAMAGE_DEALT_COLUMN}" do
    travel_to @current_time do
      service = DamageCalculatorService.new(**accuracy_caulculator_service_default_params)
      results = service.leaderboard

      assert_equal 2, results.size
      assert_equal "STEAM_1", results.first[:steam_id]
      assert_equal 2000, results.first[DamageStat::TOTAL_DAMAGE_DEALT_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is week when sorted by #{DamageStat::TOTAL_DAMAGE_DEALT_COLUMN}" do
    travel_to @current_time do
      service = DamageCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "week"))
      results = service.leaderboard

      assert_equal 3, results.size
      assert_equal "STEAM_1", results.first[:steam_id]
      assert_equal 4000, results.first[DamageStat::TOTAL_DAMAGE_DEALT_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is month when sorted by #{DamageStat::TOTAL_DAMAGE_DEALT_COLUMN}" do
    travel_to @current_time do
      service = DamageCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "month"))
      results = service.leaderboard

      assert_equal 4, results.size
      assert_equal "STEAM_4", results.first[:steam_id]
      assert_equal 15000, results.first[DamageStat::TOTAL_DAMAGE_DEALT_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is year when sorted by #{DamageStat::TOTAL_DAMAGE_DEALT_COLUMN}" do
    travel_to @current_time do
      service = DamageCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "year"))
      results = service.leaderboard

      assert_equal 5, results.size
      assert_equal "STEAM_4", results.first[:steam_id]
      assert_equal 15000, results.first[DamageStat::TOTAL_DAMAGE_DEALT_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is day when sorted by #{DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN}" do
    travel_to @current_time do
      service = DamageCalculatorService.new(**accuracy_caulculator_service_default_params.merge(sort_by: DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN))
      results = service.leaderboard

      assert_equal 2, results.size
      assert_equal "STEAM_3", results.first[:steam_id]
      assert_equal 300, results.first[DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is week when sorted by #{DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN}" do
    travel_to @current_time do
      service = DamageCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "week", sort_by: DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN))
      results = service.leaderboard

      assert_equal 3, results.size
      assert_equal "STEAM_2", results.first[:steam_id]
      assert_equal 1000, results.first[DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is month when sorted by #{DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN}" do
    travel_to @current_time do
      service = DamageCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "month", sort_by: DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN))
      results = service.leaderboard

      assert_equal 4, results.size
      assert_equal "STEAM_4", results.first[:steam_id]
      assert_equal 3000, results.first[DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN.to_sym]
    end
  end

  test "#time_filter_results returns the correct data when time_filter is year when sorted by #{DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN}" do
    travel_to @current_time do
      service = DamageCalculatorService.new(**accuracy_caulculator_service_default_params.merge(time_filter: "year", sort_by: DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN))
      results = service.leaderboard

      assert_equal 5, results.size
      assert_equal "STEAM_4", results.first[:steam_id]
      assert_equal 3000, results.first[DamageStat::TOTAL_DAMAGE_TAKEN_COLUMN.to_sym]
    end
  end

  def accuracy_caulculator_service_default_params
    {
      time_filter: "day",
      timezone: "UTC",
      limit: 10,
      formatted_table: false,
      sort_by: DamageStat::TOTAL_DAMAGE_DEALT_COLUMN,
    }
  end
end
