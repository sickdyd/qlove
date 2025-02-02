require "test_helper"

class AccuracyCalculatorServiceTest < ActiveSupport::TestCase
  setup do
    player1 = create(:player, steam_id: "STEAM_1", name: "Player One")
    player2 = create(:player, steam_id: "STEAM_2", name: "Player Two")
    player3 = create(:player, steam_id: "STEAM_3", name: "Player Three")
    player4 = create(:player, steam_id: "STEAM_4", name: "Player Four")

    @current_time = Time.new(2024, 12, 31).end_of_day

    within_the_day = @current_time - 5.hours
    within_the_week = @current_time - 1.day
    within_the_month = @current_time - 2.weeks
    within_the_year = @current_time - 3.months
    all_time = @current_time - 3.years

    travel_to @current_time do
      3.times do
        create(:stat, player: player1, created_at: within_the_day, lg_accuracy: 40, sg_accuracy: 30)
        create(:stat, player: player2, created_at: within_the_day, lg_accuracy: 30, sg_accuracy: 20)
        create(:stat, player: player3, created_at: within_the_day, lg_accuracy: 20, sg_accuracy: 10)
        create(:stat, player: player4, created_at: within_the_day, lg_accuracy: 10, sg_accuracy: 5)

        create(:stat, player: player1, created_at: within_the_week, lg_accuracy: 10, sg_accuracy: 20)
        create(:stat, player: player2, created_at: within_the_week, lg_accuracy: 70, sg_accuracy: 30)
        create(:stat, player: player3, created_at: within_the_week, lg_accuracy: 5, sg_accuracy: 15)
        create(:stat, player: player4, created_at: within_the_week, lg_accuracy: 60, sg_accuracy: 25)

        create(:stat, player: player1, created_at: within_the_month, lg_accuracy: 40, sg_accuracy: 30)
        create(:stat, player: player2, created_at: within_the_month, lg_accuracy: 30, sg_accuracy: 20)
        create(:stat, player: player3, created_at: within_the_month, lg_accuracy: 20, sg_accuracy: 10)
        create(:stat, player: player4, created_at: within_the_month, lg_accuracy: 10, sg_accuracy: 5)

        create(:stat, player: player1, created_at: within_the_year, lg_accuracy: 40, sg_accuracy: 30)
        create(:stat, player: player2, created_at: within_the_year, lg_accuracy: 30, sg_accuracy: 20)
        create(:stat, player: player3, created_at: within_the_year, lg_accuracy: 20, sg_accuracy: 10)
        create(:stat, player: player4, created_at: within_the_year, lg_accuracy: 10, sg_accuracy: 5)

        create(:stat, player: player1, created_at: all_time, lg_accuracy: 40, sg_accuracy: 30)
        create(:stat, player: player2, created_at: all_time, lg_accuracy: 30, sg_accuracy: 20)
        create(:stat, player: player3, created_at: all_time, lg_accuracy: 20, sg_accuracy: 10)
        create(:stat, player: player4, created_at: all_time, lg_accuracy: 10, sg_accuracy: 5)
      end
    end
  end

  teardown do
    travel_back
  end

  test "daily accuracy" do
    travel_to @current_time do
      @service = AccuracyCalculatorService.new(**accuracy_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal "Player One", data.first.name
      assert_equal 35, data.first.avg.to_i

      assert_equal "Player Three", data.last.name
      assert_equal 15, data.last.avg.to_i
    end
  end

  test "weekly accuracy" do
    travel_to @current_time do
      @service = AccuracyCalculatorService.new(**accuracy_calculator_service_default_params.merge(time_filter: "week", limit: 4))
      data = @service.leaderboard

      assert_equal "Player Two", data.first.name
      assert_equal 38, data.first.avg.to_i

      assert_equal "Player Three", data.last.name
      assert_equal 12, data.last.avg.to_i
    end
  end

  test "monthly accuracy" do
    travel_to @current_time do
      @service = AccuracyCalculatorService.new(**accuracy_calculator_service_default_params.merge(time_filter: "month", limit: 4))
      data = @service.leaderboard

      assert_equal "Player Two", data.first.name
      assert_equal 33, data.first.avg.to_i

      assert_equal "Player Three", data.last.name
      assert_equal 13, data.last.avg.to_i
    end
  end

  test "yearly accuracy" do
    travel_to @current_time do
      @service = AccuracyCalculatorService.new(**accuracy_calculator_service_default_params.merge(time_filter: "year", limit: 4))
      data = @service.leaderboard

      assert_equal "Player Two", data.first.name
      assert_equal 31, data.first.avg.to_i

      assert_equal "Player Three", data.last.name
      assert_equal 14, data.last.avg.to_i
    end
  end

  test "all time accuracy" do
    travel_to @current_time do
      @service = AccuracyCalculatorService.new(**accuracy_calculator_service_default_params.merge(time_filter: "all_time", limit: 4))
      data = @service.leaderboard

      assert_equal "Player One", data.first.name
      assert_equal 31, data.first.avg.to_i

      assert_equal "Player Three", data.last.name
      assert_equal 14, data.last.avg.to_i
    end
  end

  test "leaderboard respects the limit parameter" do
    travel_to @current_time do
      @service = AccuracyCalculatorService.new(**accuracy_calculator_service_default_params.merge(limit: 2))
      data = @service.leaderboard

      assert_equal 2, data.size
    end
  end

  test "leaderboard handles empty results without error" do
    travel_to @current_time + 10.years do
      @service = AccuracyCalculatorService.new(**accuracy_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal [], data
    end
  end

  test "returns a single entry given a steam_id" do
    travel_to @current_time do
      @service = AccuracyCalculatorService.new(**accuracy_calculator_service_default_params.merge(steam_id: "STEAM_1"))
      data = @service.leaderboard

      assert_equal 1, data.size
      assert_equal "Player One", data.first.name
      assert_equal 35, data.first.avg.to_i
    end
  end

  def accuracy_calculator_service_default_params
    Api::V1::BaseController::COMMON_PARAMS_DEFAULTS
      .merge(
        weapons: ["lightning", "shotgun"],
        sort_by: AccuracyCalculatorService::AVERAGE_ACCURACY_COLUMN,
        time_filter: "day",
        limit: 3,
      )
  end
end
