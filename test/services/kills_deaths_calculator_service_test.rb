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
    within_the_year = @current_time - 3.months
    all_time = @current_time - 3.years

    travel_to @current_time do
      3.times do
        # player1: 36 kills, 9 deaths, kdr: 4
        # player2: 24 kills, 21 deaths, kdr: 1.14
        # player3: 54 kills, 33 deaths, kdr: 1.64
        # player4: 45 kills, 12 deaths, kdr: 3.75
        create(:stat, player: player1, created_at: within_the_day, kills: 12, deaths: 3)
        create(:stat, player: player2, created_at: within_the_day, kills: 8, deaths: 7)
        create(:stat, player: player3, created_at: within_the_day, kills: 18, deaths: 11)
        create(:stat, player: player4, created_at: within_the_day, kills: 15, deaths: 4)

        # player1: 45 kills, 30 deaths, (45 + 36) / (30 + 9) = 81 / 39 = 2.08
        # player2: 75 kills, 45 deaths, (75 + 24) / (45 + 21) = 99 / 66 = 1.5
        # player3: 105 kills, 60 deaths, (105 + 54) / (60 + 33) = 159 / 93 = 1.71
        # player4: 135 kills, 75 deaths, (135 + 45) / (75 + 12) = 180 / 87 = 2.07
        create(:stat, player: player1, created_at: within_the_week, kills: 15, deaths: 10)
        create(:stat, player: player2, created_at: within_the_week, kills: 25, deaths: 15)
        create(:stat, player: player3, created_at: within_the_week, kills: 35, deaths: 20)
        create(:stat, player: player4, created_at: within_the_week, kills: 45, deaths: 25)

        # player1: 81 + 60 = 141 kills, 39 + 45 = 84 deaths, 141 / 84 = 1.68
        # player2: 99 + 90 = 189 kills, 66 + 60 = 126 deaths, 189 / 126 = 1.5
        # player3: 159 + 120 = 279 kills, 93 + 75 = 168 deaths, 279 / 168 = 1.66
        # player4: 180 + 150 = 330 kills, 87 + 90 = 177 deaths, 330 / 177 = 1.86
        create(:stat, player: player1, created_at: within_the_month, kills: 20, deaths: 15)
        create(:stat, player: player2, created_at: within_the_month, kills: 30, deaths: 20)
        create(:stat, player: player3, created_at: within_the_month, kills: 40, deaths: 25)
        create(:stat, player: player4, created_at: within_the_month, kills: 50, deaths: 30)

        # player1: 141 + 60 = 201 kills, 84 + 45 = 129 deaths, 201 / 129 = 1.55
        # player2: 189 + 90 = 279 kills, 126 + 60 = 186 deaths, 279 / 186 = 1.5
        # player3: 279 + 120 = 399 kills, 168 + 75 = 243 deaths, 399 / 243 = 1.64
        # player4: 330 + 150 = 480 kills, 177 + 90 = 267 deaths, 480 / 267 = 1.8
        create(:stat, player: player1, created_at: within_the_year, kills: 20, deaths: 15)
        create(:stat, player: player2, created_at: within_the_year, kills: 30, deaths: 20)
        create(:stat, player: player3, created_at: within_the_year, kills: 40, deaths: 25)
        create(:stat, player: player4, created_at: within_the_year, kills: 50, deaths: 30)

        # player1: 201 + 75 = 276 kills, 129 + 63 = 192 deaths, 276 / 192 = 1.44
        # player2: 279 + 105 = 384 kills, 186 + 75 = 261 deaths, 384 / 261 = 1.47
        # player3: 399 + 135 = 534 kills, 243 + 90 = 333 deaths, 534 / 333 = 1.6
        # player4: 480 + 165 = 645 kills, 267 + 105 = 372 deaths, 645 / 372 = 1.73
        create(:stat, player: player1, created_at: all_time, kills: 25, deaths: 21)
        create(:stat, player: player2, created_at: all_time, kills: 35, deaths: 25)
        create(:stat, player: player3, created_at: all_time, kills: 45, deaths: 30)
        create(:stat, player: player4, created_at: all_time, kills: 55, deaths: 35)
      end
    end

    AllTimeKillsDeathsStat.refresh
  end

  teardown do
    travel_back
  end

  test "daily kills" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal "Player Three", data.first.name
      assert_equal 54, data.first.total_kills.to_i

      assert_equal "Player One", data.last.name
      assert_equal 36, data.last.total_kills.to_i
    end
  end

  test "daily deaths" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(sort_by: KillsDeathsCalculatorService::TOTAL_DEATHS_COLUMN)
      )
      data = @service.leaderboard

      assert_equal "Player Three", data.first.name
      assert_equal 33, data.first.total_deaths.to_i

      assert_equal "Player Four", data.last.name
      assert_equal 12, data.last.total_deaths.to_i
    end
  end

  test "daily kdr" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(sort_by: KillsDeathsCalculatorService::KILL_DEATH_RATIO_COLUMN)
      )
      data = @service.leaderboard

      assert_equal "Player One", data.first.name
      assert_equal 4, data.first.kill_death_ratio.to_f

      assert_equal "Player Three", data.last.name
      assert_equal 1.64, data.last.kill_death_ratio.to_f
    end
  end

  test "weekly kills" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(time_filter: "week")
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 180, data.first.total_kills.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 99, data.last.total_kills.to_i
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

      assert_equal "Player Three", data.first.name
      assert_equal 93, data.first.total_deaths.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 66, data.last.total_deaths.to_i
    end
  end

  test "weekly kdr" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(
          sort_by: KillsDeathsCalculatorService::KILL_DEATH_RATIO_COLUMN,
          time_filter: "week"
        )
      )
      data = @service.leaderboard

      assert_equal "Player One", data.first.name
      assert_equal 2.08, data.first.kill_death_ratio.to_f

      assert_equal "Player Three", data.last.name
      assert_equal 1.71, data.last.kill_death_ratio.to_f
    end
  end

  test "monthly kills" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(time_filter: "month")
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 330, data.first.total_kills.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 189, data.last.total_kills.to_i
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
      assert_equal 177, data.first.total_deaths.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 126, data.last.total_deaths.to_i
    end
  end

  test "monthly kdr" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(
          sort_by: KillsDeathsCalculatorService::KILL_DEATH_RATIO_COLUMN,
          time_filter: "month"
        )
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 1.86, data.first.kill_death_ratio.to_f

      assert_equal "Player Three", data.last.name
      assert_equal 1.66, data.last.kill_death_ratio.to_f
    end
  end

  test "yearly kills" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(time_filter: "year")
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 480, data.first.total_kills.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 279, data.last.total_kills.to_i
    end
  end

  test "yearly deaths" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(
          time_filter: "year",
          sort_by: KillsDeathsCalculatorService::TOTAL_DEATHS_COLUMN
        )
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 267, data.first.total_deaths.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 186, data.last.total_deaths.to_i
    end
  end

  test "yearly kdr" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(
          sort_by: KillsDeathsCalculatorService::KILL_DEATH_RATIO_COLUMN,
          time_filter: "year"
        )
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 1.8, data.first.kill_death_ratio.to_f

      assert_equal "Player One", data.last.name
      assert_equal 1.56, data.last.kill_death_ratio.to_f
    end
  end

  test "all time kills" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(time_filter: "all_time")
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 645, data.first.total_kills.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 384, data.last.total_kills.to_i
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
      assert_equal 372, data.first.total_deaths.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 261, data.last.total_deaths.to_i
    end
  end

  test "all time kdr" do
    travel_to @current_time do
      @service = KillsDeathsCalculatorService.new(**kills_deaths_calculator_service_default_params
        .merge(
          sort_by: KillsDeathsCalculatorService::KILL_DEATH_RATIO_COLUMN,
          time_filter: "all_time"
        )
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 1.73, data.first.kill_death_ratio.to_f

      assert_equal "Player Two", data.last.name
      assert_equal 1.47, data.last.kill_death_ratio.to_f
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
