require "test_helper"

class MedalsCalculatorServiceTest < ActiveSupport::TestCase
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
        # player1 40 * 3 + 30 * 3 = 210
        # player2 30 * 3 + 20 * 3 = 150
        # player3 20 * 3 + 10 * 3 = 90
        # player4 10 * 3 + 5 * 3 = 45
        create(:stat, player: player1, created_at: within_the_day, **zeroed_medals.merge(accuracy: 40, excellent: 30))
        create(:stat, player: player2, created_at: within_the_day, **zeroed_medals.merge(accuracy: 30, excellent: 20))
        create(:stat, player: player3, created_at: within_the_day, **zeroed_medals.merge(accuracy: 20, excellent: 10))
        create(:stat, player: player4, created_at: within_the_day, **zeroed_medals.merge(accuracy: 10, excellent: 5))

        # player1 210 + 10 * 3 + 20 * 3 = 300
        # player2 150 + 70 * 3 + 30 * 3 = 450
        # player3 90 + 5 * 3 + 15 * 3 = 150
        # player4 45 + 60 * 3 + 27 * 3 = 306
        create(:stat, player: player1, created_at: within_the_week, **zeroed_medals.merge(accuracy: 10, excellent: 20))
        create(:stat, player: player2, created_at: within_the_week, **zeroed_medals.merge(accuracy: 70, excellent: 30))
        create(:stat, player: player3, created_at: within_the_week, **zeroed_medals.merge(accuracy: 5, excellent: 15))
        create(:stat, player: player4, created_at: within_the_week, **zeroed_medals.merge(accuracy: 60, excellent: 27))

        # player1 300 + 40 * 3 + 30 * 3 = 510
        # player2 450 + 30 * 3 + 20 * 3 = 600
        # player3 150 + 20 * 3 + 10 * 3 = 240
        # player4 306 + 10 * 3 + 5 * 3 = 351
        create(:stat, player: player1, created_at: within_the_month, **zeroed_medals.merge(accuracy: 40, excellent: 30))
        create(:stat, player: player2, created_at: within_the_month, **zeroed_medals.merge(accuracy: 30, excellent: 20))
        create(:stat, player: player3, created_at: within_the_month, **zeroed_medals.merge(accuracy: 20, excellent: 10))
        create(:stat, player: player4, created_at: within_the_month, **zeroed_medals.merge(accuracy: 10, excellent: 5))

        # player1 510 + 20 * 3 + 20 * 3 = 630
        # player2 600 + 30 * 3 + 10 * 3 = 720
        # player3 240 + 10 * 3 + 20 * 3 = 330
        # player4 351 + 10 * 3 + 15 * 3 = 426
        create(:stat, player: player1, created_at: within_the_year, **zeroed_medals.merge(accuracy: 20, excellent: 20))
        create(:stat, player: player2, created_at: within_the_year, **zeroed_medals.merge(accuracy: 30, excellent: 10))
        create(:stat, player: player3, created_at: within_the_year, **zeroed_medals.merge(accuracy: 10, excellent: 20))
        create(:stat, player: player4, created_at: within_the_year, **zeroed_medals.merge(accuracy: 10, excellent: 15))

        # player1 630 + 40 * 3 + 30 * 3 = 840
        # player2 720 + 30 * 3 + 20 * 3 = 870
        # player3 330 + 20 * 3 + 10 * 3 = 420
        # player4 426 + 10 * 3 + 5 * 3 = 471
        create(:stat, player: player1, created_at: all_time, **zeroed_medals.merge(accuracy: 40, excellent: 30))
        create(:stat, player: player2, created_at: all_time, **zeroed_medals.merge(accuracy: 30, excellent: 20))
        create(:stat, player: player3, created_at: all_time, **zeroed_medals.merge(accuracy: 20, excellent: 10))
        create(:stat, player: player4, created_at: all_time, **zeroed_medals.merge(accuracy: 10, excellent: 5))
      end
    end
  end

  teardown do
    travel_back
  end

  test "daily medals" do
    travel_to @current_time do
      @service = MedalsCalculatorService.new(**medals_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal "Player One", data.first.name
      assert_equal 210, data.first.total_medals.to_i

      assert_equal "Player Three", data.last.name
      assert_equal 90, data.last.total_medals.to_i
    end
  end

  test "weekly medals" do
    travel_to @current_time do
      @service = MedalsCalculatorService.new(**medals_calculator_service_default_params
        .merge(time_filter: "week")
      )

      data = @service.leaderboard

      assert_equal "Player Two", data.first.name
      assert_equal 450, data.first.total_medals.to_i

      assert_equal "Player One", data.last.name
      assert_equal 300, data.last.total_medals.to_i
    end
  end

  test "monthly medals" do
    travel_to @current_time do
      @service = MedalsCalculatorService.new(**medals_calculator_service_default_params
        .merge(time_filter: "month")
      )

      data = @service.leaderboard

      assert_equal "Player Two", data.first.name
      assert_equal 600, data.first.total_medals.to_i

      assert_equal "Player Four", data.last.name
      assert_equal 351, data.last.total_medals.to_i
    end
  end

  test "yearly medals" do
    travel_to @current_time do
      @service = MedalsCalculatorService.new(**medals_calculator_service_default_params
        .merge(time_filter: "year")
      )

      data = @service.leaderboard

      assert_equal "Player Two", data.first.name
      assert_equal 720, data.first.total_medals.to_i

      assert_equal "Player Four", data.last.name
      assert_equal 426, data.last.total_medals.to_i
    end
  end

  test "all time medals" do
    travel_to @current_time do
      @service = MedalsCalculatorService.new(**medals_calculator_service_default_params
        .merge(time_filter: "all_time")
      )

      data = @service.leaderboard

      assert_equal "Player Two", data.first.name
      assert_equal 870, data.first.total_medals.to_i

      assert_equal "Player Four", data.last.name
      assert_equal 471, data.last.total_medals.to_i
    end
  end

  def medals_calculator_service_default_params
    Api::V1::BaseController::COMMON_PARAMS_DEFAULTS
      .merge(
        sort_by: MedalsCalculatorService::TOTAL_MEDALS_COLUMN,
        medals: ["accuracy", "excellent"],
        time_filter: "day",
        limit: 3,
      )
  end

  def zeroed_medals
    MedalValidatable::ALL_MEDALS.index_with(nil)
  end
end
