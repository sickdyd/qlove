require "test_helper"

class DamageCalculatorServiceTest < ActiveSupport::TestCase
  setup do
    player1 = create(:player, steam_id: "STEAM_1", name: "Player One")
    player2 = create(:player, steam_id: "STEAM_2", name: "Player Two")
    player3 = create(:player, steam_id: "STEAM_3", name: "Player Three")
    player4 = create(:player, steam_id: "STEAM_4", name: "Player Four")

    @current_time = Time.new(2024, 12, 31).end_of_day

    travel_to @current_time do
      3.times do
        within_the_day = @current_time - 5.hours
        # Need to make sure this is within the current week, which starts on Sunday 29th
        # This will set the day to Tuesday
        within_the_week = @current_time - 1.day
        within_the_month = @current_time - 2.weeks
        all_time = @current_time - 3.months

        create(:stat, player: player1, created_at: within_the_day, damage_dealt: 1000, damage_taken: 2000)
        create(:stat, player: player2, created_at: within_the_day, damage_dealt: 2000, damage_taken: 3000)
        create(:stat, player: player3, created_at: within_the_day, damage_dealt: 3000, damage_taken: 4000)
        create(:stat, player: player4, created_at: within_the_day, damage_dealt: 4000, damage_taken: 1000)

        create(:stat, player: player1, created_at: within_the_week, damage_dealt: 1500, damage_taken: 2500)
        create(:stat, player: player2, created_at: within_the_week, damage_dealt: 2500, damage_taken: 3500)
        create(:stat, player: player3, created_at: within_the_week, damage_dealt: 3500, damage_taken: 4500)
        create(:stat, player: player4, created_at: within_the_week, damage_dealt: 4500, damage_taken: 1500)

        create(:stat, player: player1, created_at: within_the_month, damage_dealt: 2000, damage_taken: 3000)
        create(:stat, player: player2, created_at: within_the_month, damage_dealt: 3000, damage_taken: 4000)
        create(:stat, player: player3, created_at: within_the_month, damage_dealt: 4000, damage_taken: 5000)
        create(:stat, player: player4, created_at: within_the_month, damage_dealt: 5000, damage_taken: 2000)

        create(:stat, player: player1, created_at: all_time, damage_dealt: 2500, damage_taken: 3500)
        create(:stat, player: player2, created_at: all_time, damage_dealt: 3500, damage_taken: 4500)
        create(:stat, player: player3, created_at: all_time, damage_dealt: 4500, damage_taken: 5500)
        create(:stat, player: player4, created_at: all_time, damage_dealt: 5500, damage_taken: 2500)
      end
    end
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
