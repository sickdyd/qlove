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
        # player1, damage_dealt: 1000 * 3 = 3000, damage_taken: 2000 * 3 = 6000
        # player2, damage_dealt: 2000 * 3 = 6000, damage_taken: 3000 * 3 = 9000
        # player3, damage_dealt: 3000 * 3 = 9000, damage_taken: 4000 * 3 = 12000
        # player4, damage_dealt: 4000 * 3 = 12000, damage_taken: 1000 * 3 = 3000
        create(:stat, player: player1, created_at: within_the_day, damage_dealt: 1000, damage_taken: 2000)
        create(:stat, player: player2, created_at: within_the_day, damage_dealt: 2000, damage_taken: 3000)
        create(:stat, player: player3, created_at: within_the_day, damage_dealt: 3000, damage_taken: 4000)
        create(:stat, player: player4, created_at: within_the_day, damage_dealt: 4000, damage_taken: 1000)

        # player1: damage_dealt: 3000 + 4500 = 7500, damage_taken: 6000 + 7500 = 13500
        # player2: damage_dealt: 6000 + 7500 = 13500, damage_taken: 9000 + 10500 = 19500
        # player3: damage_dealt: 9000 + 10500 = 19500, damage_taken: 12000 + 13500 = 25500
        # player4: damage_dealt: 12000 + 13500 = 25500, damage_taken: 3000 + 4500 = 7500
        create(:stat, player: player1, created_at: within_the_week, damage_dealt: 1500, damage_taken: 2500)
        create(:stat, player: player2, created_at: within_the_week, damage_dealt: 2500, damage_taken: 3500)
        create(:stat, player: player3, created_at: within_the_week, damage_dealt: 3500, damage_taken: 4500)
        create(:stat, player: player4, created_at: within_the_week, damage_dealt: 4500, damage_taken: 1500)

        # player1: damage_dealt: 7500 + 6000 = 13500, damage_taken: 13500 + 9000 = 22500
        # player2: damage_dealt: 13500 + 9000 = 22500, damage_taken: 19500 + 12000 = 31500
        # player3: damage_dealt: 19500 + 12000 = 31500, damage_taken: 25500 + 15000 = 40500
        # player4: damage_dealt: 25500 + 15000 = 40500, damage_taken: 7500 + 6000 = 13500
        create(:stat, player: player1, created_at: within_the_month, damage_dealt: 2000, damage_taken: 3000)
        create(:stat, player: player2, created_at: within_the_month, damage_dealt: 3000, damage_taken: 4000)
        create(:stat, player: player3, created_at: within_the_month, damage_dealt: 4000, damage_taken: 5000)
        create(:stat, player: player4, created_at: within_the_month, damage_dealt: 5000, damage_taken: 2000)

        # player1: damage_dealt: 13500 + 7500 = 21000, damage_taken: 22500 + 10500 = 33000
        # player2: damage_dealt: 22500 + 10500 = 33000, damage_taken: 31500 + 13500 = 45000
        # player3: damage_dealt: 31500 + 13500 = 45000, damage_taken: 40500 + 16500 = 57000
        # player4: damage_dealt: 40500 + 16500 = 57000, damage_taken: 13500 + 7500 = 21000
        create(:stat, player: player1, created_at: within_the_year, damage_dealt: 2500, damage_taken: 3500)
        create(:stat, player: player2, created_at: within_the_year, damage_dealt: 3500, damage_taken: 4500)
        create(:stat, player: player3, created_at: within_the_year, damage_dealt: 4500, damage_taken: 5500)
        create(:stat, player: player4, created_at: within_the_year, damage_dealt: 5500, damage_taken: 2500)

        # player1: damage_dealt: 21000 + 7500 = 28500, damage_taken: 33000 + 10500 = 43500
        # player2: damage_dealt: 33000 + 10500 = 43500, damage_taken: 45000 + 13500 = 58500
        # player3: damage_dealt: 45000 + 13500 = 58500, damage_taken: 57000 + 16500 = 73500
        # player4: damage_dealt: 57000 + 16500 = 73500, damage_taken: 21000 + 7500 = 28500
        create(:stat, player: player1, created_at: all_time, damage_dealt: 2500, damage_taken: 3500)
        create(:stat, player: player2, created_at: all_time, damage_dealt: 3500, damage_taken: 4500)
        create(:stat, player: player3, created_at: all_time, damage_dealt: 4500, damage_taken: 5500)
        create(:stat, player: player4, created_at: all_time, damage_dealt: 5500, damage_taken: 2500)
      end
    end

    AllTimeDamageStat.refresh
  end

  teardown do
    travel_back
  end

  test "daily damage dealt" do
    travel_to @current_time do
      @service = DamageCalculatorService.new(**damage_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 12000, data.first.total_damage_dealt.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 6000, data.last.total_damage_dealt.to_i
    end
  end

  test "daily damage taken" do
    travel_to @current_time do
      @service = DamageCalculatorService.new(**damage_calculator_service_default_params
        .merge(sort_by: DamageCalculatorService::TOTAL_DAMAGE_TAKEN_COLUMN)
      )
      data = @service.leaderboard

      assert_equal "Player Three", data.first.name
      assert_equal 12000, data.first.total_damage_taken.to_i

      assert_equal "Player One", data.last.name
      assert_equal 6000, data.last.total_damage_taken.to_i
    end
  end

  test "weekly damage dealt" do
    travel_to @current_time do
      @service = DamageCalculatorService.new(**damage_calculator_service_default_params
        .merge(time_filter: "week")
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 25500, data.first.total_damage_dealt.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 13500, data.last.total_damage_dealt.to_i
    end
  end

  test "weekly damage taken" do
    travel_to @current_time do
      @service = DamageCalculatorService.new(**damage_calculator_service_default_params
        .merge(
          time_filter: "week",
          sort_by: DamageCalculatorService::TOTAL_DAMAGE_TAKEN_COLUMN
        )
      )
      data = @service.leaderboard

      assert_equal "Player Three", data.first.name
      assert_equal 25500, data.first.total_damage_taken.to_i

      assert_equal "Player One", data.last.name
      assert_equal 13500, data.last.total_damage_taken.to_i
    end
  end

  test "monthly damage dealt" do
    travel_to @current_time do
      @service = DamageCalculatorService.new(**damage_calculator_service_default_params
        .merge(time_filter: "month")
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 40500, data.first.total_damage_dealt.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 22500, data.last.total_damage_dealt.to_i
    end
  end

  test "monthly damage taken" do
    travel_to @current_time do
      @service = DamageCalculatorService.new(**damage_calculator_service_default_params
        .merge(
          time_filter: "month",
          sort_by: DamageCalculatorService::TOTAL_DAMAGE_TAKEN_COLUMN
        )
      )
      data = @service.leaderboard

      assert_equal "Player Three", data.first.name
      assert_equal 40500, data.first.total_damage_taken.to_i

      assert_equal "Player One", data.last.name
      assert_equal 22500, data.last.total_damage_taken.to_i
    end
  end

  test "yearly damage dealt" do
    travel_to @current_time do
      @service = DamageCalculatorService.new(**damage_calculator_service_default_params
        .merge(time_filter: "year")
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 57000, data.first.total_damage_dealt.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 33000, data.last.total_damage_dealt.to_i
    end
  end

  test "yearly damage taken" do
    travel_to @current_time do
      @service = DamageCalculatorService.new(**damage_calculator_service_default_params
        .merge(
          time_filter: "year",
          sort_by: DamageCalculatorService::TOTAL_DAMAGE_TAKEN_COLUMN
        )
      )
      data = @service.leaderboard

      assert_equal "Player Three", data.first.name
      assert_equal 57000, data.first.total_damage_taken.to_i

      assert_equal "Player One", data.last.name
      assert_equal 33000, data.last.total_damage_taken.to_i
    end
  end

  test "all time damage dealt" do
    travel_to @current_time do
      @service = DamageCalculatorService.new(**damage_calculator_service_default_params
        .merge(time_filter: "all_time")
      )
      data = @service.leaderboard

      assert_equal "Player Four", data.first.name
      assert_equal 73500, data.first.total_damage_dealt.to_i

      assert_equal "Player Two", data.last.name
      assert_equal 43500, data.last.total_damage_dealt.to_i
    end
  end

  test "all time damage taken" do
    travel_to @current_time do
      @service = DamageCalculatorService.new(**damage_calculator_service_default_params
        .merge(
          time_filter: "all_time",
          sort_by: DamageCalculatorService::TOTAL_DAMAGE_TAKEN_COLUMN
        )
      )
      data = @service.leaderboard

      assert_equal "Player Three", data.first.name
      assert_equal 73500, data.first.total_damage_taken.to_i

      assert_equal "Player One", data.last.name
      assert_equal 43500, data.last.total_damage_taken.to_i
    end
  end

  test "leaderboard handles empty results without error" do
    travel_to @current_time + 10.years do
      @service = DamageCalculatorService.new(**damage_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal [], data
    end
  end

  def damage_calculator_service_default_params
    Api::V1::BaseController::COMMON_PARAMS_DEFAULTS
      .merge(
        sort_by: DamageCalculatorService::TOTAL_DAMAGE_DEALT_COLUMN,
        time_filter: "day",
        limit: 3,
      )
  end
end
