require "test_helper"

class WinsLossesCalculatorServiceTest < ActiveSupport::TestCase
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
        # player1 wins 9, loses 9
        # player2 wins 6, loses 3
        # player3 wins 3, loses 0
        # player4 wins 0, loses 6
        create(:stat, player: player1, created_at: within_the_day, win: 1, lose: 0)
        create(:stat, player: player1, created_at: within_the_day, win: 1, lose: 0)
        create(:stat, player: player1, created_at: within_the_day, win: 1, lose: 0)
        create(:stat, player: player1, created_at: within_the_day, win: 0, lose: 1)
        create(:stat, player: player1, created_at: within_the_day, win: 0, lose: 1)
        create(:stat, player: player1, created_at: within_the_day, win: 0, lose: 1)
        create(:stat, player: player2, created_at: within_the_day, win: 1, lose: 0)
        create(:stat, player: player2, created_at: within_the_day, win: 1, lose: 0)
        create(:stat, player: player2, created_at: within_the_day, win: 0, lose: 1)
        create(:stat, player: player3, created_at: within_the_day, win: 1, lose: 0)
        create(:stat, player: player4, created_at: within_the_day, win: 0, lose: 1)
        create(:stat, player: player4, created_at: within_the_day, win: 0, lose: 1)

        # player1 wins 3, loses 0
        # player2 wins 3, loses 0
        # player3 wins 3, loses 0
        # player4 wins 0, loses 6
        create(:stat, player: player1, created_at: within_the_week, win: 1, lose: 0)
        create(:stat, player: player2, created_at: within_the_week, win: 1, lose: 0)
        create(:stat, player: player3, created_at: within_the_week, win: 1, lose: 0)
        create(:stat, player: player4, created_at: within_the_week, win: 0, lose: 1)
        create(:stat, player: player4, created_at: within_the_week, win: 0, lose: 1)

        # player1 wins 3, loses 0
        # player2 wins 3, loses 0
        # player3 wins 3, loses 0
        # player4 wins 0, loses 3
        create(:stat, player: player1, created_at: within_the_month, win: 1, lose: 0)
        create(:stat, player: player2, created_at: within_the_month, win: 1, lose: 0)
        create(:stat, player: player3, created_at: within_the_month, win: 1, lose: 0)
        create(:stat, player: player4, created_at: within_the_month, win: 0, lose: 1)

        # player1: wins 3, loses 0
        # player2: wins 3, loses 0
        # player3: wins 3, loses 0
        # player4: wins 0, loses 3
        create(:stat, player: player1, created_at: within_the_year, win: 1, lose: 0)
        create(:stat, player: player2, created_at: within_the_year, win: 1, lose: 0)
        create(:stat, player: player3, created_at: within_the_year, win: 1, lose: 0)
        create(:stat, player: player4, created_at: within_the_year, win: 0, lose: 1)

        # player1 wins 3, loses 0
        # player2 wins 3, loses 0
        # player3 wins 3, loses 0
        # player4 wins 0, loses 3
        create(:stat, player: player1, created_at: all_time, win: 1, lose: 0)
        create(:stat, player: player2, created_at: all_time, win: 1, lose: 0)
        create(:stat, player: player3, created_at: all_time, win: 1, lose: 0)
        create(:stat, player: player4, created_at: all_time, win: 0, lose: 1)
      end
    end

    AllTimeWinsLossesStat.refresh
  end

  teardown do
    travel_back
  end

  test "daily wins, sorted by #{WinsLossesCalculatorService::TOTAL_WINS_COLUMN}" do
    travel_to @current_time do
      @service = WinsLossesCalculatorService.new(**wins_losses_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal "Player One", data.first.name
      assert_equal 9, data.first.total_wins.to_i

      assert_equal "Player Three", data.last.name
      assert_equal 3, data.last.total_wins.to_i
    end
  end

  test "daily losses, sorted by #{WinsLossesCalculatorService::TOTAL_LOSSES_COLUMN}" do
    travel_to @current_time do
      @service = WinsLossesCalculatorService.new(**wins_losses_calculator_service_default_params
        .merge(sort_by: WinsLossesCalculatorService::TOTAL_LOSSES_COLUMN)
      )
      data = @service.leaderboard

      assert_equal "Player One", data.first.name
      assert_equal 9, data.first.total_losses.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 3, data.last.total_losses.to_i
    end
  end

  test "weekly wins, sorted by #{WinsLossesCalculatorService::TOTAL_WINS_COLUMN}" do
    travel_to @current_time do
      @service = WinsLossesCalculatorService.new(**wins_losses_calculator_service_default_params
        .merge(time_filter: "week")
      )
      data = @service.leaderboard

      assert_equal "Player One", data.first.name
      assert_equal 12, data.first.total_wins.to_i

      assert_equal "Player Three", data.last.name
      assert_equal 6, data.last.total_wins.to_i
    end
  end

  test "weekly losses, sorted by #{WinsLossesCalculatorService::TOTAL_LOSSES_COLUMN}" do
    travel_to @current_time do
      @service = WinsLossesCalculatorService.new(**wins_losses_calculator_service_default_params
        .merge(
          time_filter: "week",
          sort_by: WinsLossesCalculatorService::TOTAL_LOSSES_COLUMN
        )
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 12, data.first.total_losses.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 3, data.last.total_losses.to_i
    end
  end

  test "monthly wins, sorted by #{WinsLossesCalculatorService::TOTAL_WINS_COLUMN}" do
    travel_to @current_time do
      @service = WinsLossesCalculatorService.new(**wins_losses_calculator_service_default_params
        .merge(time_filter: "month")
      )
      data = @service.leaderboard

      assert_equal "Player One", data.first.name
      assert_equal 15, data.first.total_wins.to_i

      assert_equal "Player Three", data.last.name
      assert_equal 9, data.last.total_wins.to_i
    end
  end

  test "monthly losses, sorted by #{WinsLossesCalculatorService::TOTAL_LOSSES_COLUMN}" do
    travel_to @current_time do
      @service = WinsLossesCalculatorService.new(**wins_losses_calculator_service_default_params
        .merge(
          time_filter: "month",
          sort_by: WinsLossesCalculatorService::TOTAL_LOSSES_COLUMN
        )
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 15, data.first.total_losses.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 3, data.last.total_losses.to_i
    end
  end

  test "yearly wins, sorted by #{WinsLossesCalculatorService::TOTAL_WINS_COLUMN}" do
    travel_to @current_time do
      @service = WinsLossesCalculatorService.new(**wins_losses_calculator_service_default_params
        .merge(time_filter: "year")
      )
      data = @service.leaderboard

      assert_equal "Player One", data.first.name
      assert_equal 18, data.first.total_wins.to_i

      assert_equal "Player Three", data.last.name
      assert_equal 12, data.last.total_wins.to_i
    end
  end

  test "yearly losses, sorted by #{WinsLossesCalculatorService::TOTAL_LOSSES_COLUMN}" do
    travel_to @current_time do
      @service = WinsLossesCalculatorService.new(**wins_losses_calculator_service_default_params
        .merge(
          time_filter: "year",
          sort_by: WinsLossesCalculatorService::TOTAL_LOSSES_COLUMN
        )
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 18, data.first.total_losses.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 3, data.last.total_losses.to_i
    end
  end

  test "all time wins, sorted by #{WinsLossesCalculatorService::TOTAL_WINS_COLUMN}" do
    travel_to @current_time do
      @service = WinsLossesCalculatorService.new(**wins_losses_calculator_service_default_params
        .merge(time_filter: "all_time")
      )
      data = @service.leaderboard

      assert_equal "Player One", data.first.name
      assert_equal 21, data.first.total_wins.to_i

      assert_equal "Player Three", data.last.name
      assert_equal 15, data.last.total_wins.to_i
    end
  end

  test "all time losses, sorted by #{WinsLossesCalculatorService::TOTAL_LOSSES_COLUMN}" do
    travel_to @current_time do
      @service = WinsLossesCalculatorService.new(**wins_losses_calculator_service_default_params
        .merge(
          time_filter: "all_time",
          sort_by: WinsLossesCalculatorService::TOTAL_LOSSES_COLUMN
        )
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 21, data.first.total_losses.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 3, data.last.total_losses.to_i
    end
  end

  test "leaderboard handles empty results without error" do
    travel_to @current_time + 10.years do
      @service = WinsLossesCalculatorService.new(**wins_losses_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal [], data
    end
  end

  def wins_losses_calculator_service_default_params
    Api::V1::BaseController::COMMON_PARAMS_DEFAULTS
      .merge(
        sort_by: WinsLossesCalculatorService::TOTAL_WINS_COLUMN,
        time_filter: "day",
        limit: 3,
      )
  end
end
