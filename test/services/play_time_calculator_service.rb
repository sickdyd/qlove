require "test_helper"

class DamageCalculatorServiceTest < ActiveSupport::TestCase
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
        create(:stat, player: player1, created_at: within_the_day, play_time: 300)
        create(:stat, player: player2, created_at: within_the_day, play_time: 600)
        create(:stat, player: player3, created_at: within_the_day, play_time: 900)
        create(:stat, player: player4, created_at: within_the_day, play_time: 1200)

        create(:stat, player: player1, created_at: within_the_week, play_time: 300)
        create(:stat, player: player2, created_at: within_the_week, play_time: 600)
        create(:stat, player: player3, created_at: within_the_week, play_time: 900)
        create(:stat, player: player4, created_at: within_the_week, play_time: 1200)

        create(:stat, player: player1, created_at: within_the_month, play_time: 300)
        create(:stat, player: player2, created_at: within_the_month, play_time: 600)
        create(:stat, player: player3, created_at: within_the_month, play_time: 900)
        create(:stat, player: player4, created_at: within_the_month, play_time: 1200)

        create(:stat, player: player1, created_at: within_the_year, play_time: 300)
        create(:stat, player: player2, created_at: within_the_year, play_time: 600)
        create(:stat, player: player3, created_at: within_the_year, play_time: 900)
        create(:stat, player: player4, created_at: within_the_year, play_time: 1200)

        create(:stat, player: player1, created_at: all_time, play_time: 300)
        create(:stat, player: player2, created_at: all_time, play_time: 600)
        create(:stat, player: player3, created_at: all_time, play_time: 900)
        create(:stat, player: player4, created_at: all_time, play_time: 1200)
      end
    end

    AllTimePlayTimeStat.refresh
  end

  teardown do
    travel_back
  end

  test "daily time_played" do
    travel_to @current_time do
      @service = PlayTimeCalculatorService.new(**play_time_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal "1h", data.first[PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN]

      assert_equal "Player Two", data.last.name
      assert_equal "30m", data.last[PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN]
    end
  end

  test "weekly time_played" do
    travel_to @current_time do
      @service = PlayTimeCalculatorService.new(**play_time_calculator_service_default_params.merge(time_filter: "week"))
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal "2h", data.first[PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN]

      assert_equal "Player Two", data.last.name
      assert_equal "1h", data.last[PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN]
    end
  end

  test "monthly time_played" do
    travel_to @current_time do
      @service = PlayTimeCalculatorService.new(**play_time_calculator_service_default_params.merge(time_filter: "month"))
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal "3h", data.first[PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN]

      assert_equal "Player Two", data.last.name
      assert_equal "1h30m", data.last[PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN]
    end
  end

  test "yearly time_played" do
    travel_to @current_time do
      @service = PlayTimeCalculatorService.new(**play_time_calculator_service_default_params.merge(time_filter: "year"))
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal "4h", data.first[PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN]

      assert_equal "Player Two", data.last.name
      assert_equal "2h", data.last[PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN]
    end
  end

  test "all_time time_played" do
    travel_to @current_time do
      @service = PlayTimeCalculatorService.new(**play_time_calculator_service_default_params.merge(time_filter: "all_time"))
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal "5h", data.first[PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN]

      assert_equal "Player Two", data.last.name
      assert_equal "2h30m", data.last[PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN]
    end
  end

  def play_time_calculator_service_default_params
    Api::V1::BaseController::COMMON_PARAMS_DEFAULTS
      .merge(
          sort_by: PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN,
        time_filter: "day",
        limit: 3,
      )
  end
end
