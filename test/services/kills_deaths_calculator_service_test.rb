require "test_helper"

class KillsDeathsCalculatorServiceTest < ActiveSupport::TestCase
  setup do
    player1 = create(:player, steam_id: "STEAM_1", name: "Player One")
    player2 = create(:player, steam_id: "STEAM_2", name: "Player Two")
    player3 = create(:player, steam_id: "STEAM_3", name: "Player Three")
    player4 = create(:player, steam_id: "STEAM_4", name: "Player Four")

    @current_time = Time.new(2024, 12, 31).end_of_day

    within_the_day = @current_time - 5.hours
    within_the_week = @current_time - 1.day
    within_the_month = @current_time - 2.weeks
    all_time = @current_time - 3.months

    travel_to @current_time do
      3.times do
        create(:stat, player: player1, created_at: within_the_day, kills: 10, deaths: 5)
        create(:stat, player: player2, created_at: within_the_day, kills: 20, deaths: 10)
        create(:stat, player: player3, created_at: within_the_day, kills: 30, deaths: 15)
        create(:stat, player: player4, created_at: within_the_day, kills: 40, deaths: 20)

        create(:stat, player: player1, created_at: within_the_week, kills: 15, deaths: 10)
        create(:stat, player: player2, created_at: within_the_week, kills: 25, deaths: 15)
        create(:stat, player: player3, created_at: within_the_week, kills: 35, deaths: 20)
        create(:stat, player: player4, created_at: within_the_week, kills: 45, deaths: 25)

        create(:stat, player: player1, created_at: within_the_month, kills: 20, deaths: 15)
        create(:stat, player: player2, created_at: within_the_month, kills: 30, deaths: 20)
        create(:stat, player: player3, created_at: within_the_month, kills: 40, deaths: 25)
        create(:stat, player: player4, created_at: within_the_month, kills: 50, deaths: 30)

        create(:stat, player: player1, created_at: all_time, kills: 25, deaths: 20)
        create(:stat, player: player2, created_at: all_time, kills: 35, deaths: 25)
        create(:stat, player: player3, created_at: all_time, kills: 45, deaths: 30)
        create(:stat, player: player4, created_at: all_time, kills: 55, deaths: 35)
      end
    end
  end

  teardown do
    travel_back
  end

  test "daily kills" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 120, data.first.total_kills.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 60, data.last.total_kills.to_i
    end
  end

  test "daily deaths" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(sort_by: KillsDeathsCalculatorService::TOTAL_DEATHS_COLUMN)
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 60, data.first.total_deaths.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 30, data.last.total_deaths.to_i
    end
  end

  test "weekly kills" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(time_filter: "week")
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 255, data.first.total_kills.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 135, data.last.total_kills.to_i
    end
  end

  test "weekly deaths" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(
          time_filter: "week",
          sort_by: KillsDeathsCalculatorService::TOTAL_DEATHS_COLUMN
        )
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 135, data.first.total_deaths.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 75, data.last.total_deaths.to_i
    end
  end

  test "monthly kills" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(time_filter: "month")
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 405, data.first.total_kills.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 225, data.last.total_kills.to_i
    end
  end

  test "monthly deaths" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(
          time_filter: "month",
          sort_by: KillsDeathsCalculatorService::TOTAL_DEATHS_COLUMN
        )
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 225, data.first.total_deaths.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 135, data.last.total_deaths.to_i
    end
  end

  test "all time kills" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(time_filter: "all_time")
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 570, data.first.total_kills.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 330, data.last.total_kills.to_i
    end
  end

  test "all time deaths" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(
          time_filter: "all_time",
          sort_by: KillsDeathsCalculatorService::TOTAL_DEATHS_COLUMN
        )
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 330, data.first.total_deaths.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 210, data.last.total_deaths.to_i
    end
  end

  test "leaderboard handles empty results without error" do
    travel_to @current_time + 10.years do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal [], data
    end
  end

  def kills_deaths_calculator_service_default_params
    Api::V1::BaseController::COMMON_PARAMS_DEFAULTS
      .merge(
        sort_by: KillsDeathsCalculatorService::TOTAL_KILLS_COLUMN,
        time_filter: "day",
        limit: 3,
      )
  end
end
