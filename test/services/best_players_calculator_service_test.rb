require "test_helper"

class BestPlayersCalculatorServiceTest < ActiveSupport::TestCase
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
      player_stat = zeroed_stats.merge(damage_dealt: 10000, lg_accuracy: 100, kills: 10)
      create(:stat, player: player1, created_at: within_the_day, **player_stat)

      player_stat = zeroed_stats.merge(lg_accuracy: 50, damage_dealt: 5000, kills: 5)
      create(:stat, player: player2, created_at: within_the_day, **player_stat)

      player_stat = zeroed_stats.merge(lg_accuracy: 0, damage_dealt: 0, kills: 0)
      create(:stat, player: player3, created_at: within_the_day, **player_stat)
    end

    AllTimeDamageStat.refresh
    AllTimeKillsDeathsStat.refresh
  end

  teardown do
    travel_back
  end

  test "daily best players" do
    travel_to @current_time do
      @service = BestPlayersCalculatorService.new(**best_players_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal "Player One", data.first.name
      assert_equal 100, data.first.strength

      assert_equal "Player Two", data.second.name
      assert_equal 50, data.second.strength

      assert_equal "Player Three", data.last.name
      assert_equal 0, data.last.strength
    end
  end

  test "leaderboard handles empty results without error" do
    travel_to @current_time + 10.years do
      @service = BestPlayersCalculatorService.new(**best_players_calculator_service_default_params)
      data = @service.leaderboard

      assert_equal [], data
    end
  end

  def best_players_calculator_service_default_params
    Api::V1::BaseController::COMMON_PARAMS_DEFAULTS
      .merge(
        weapons: [ "lightning" ],
        sort_by: BestPlayersCalculatorService::SORT_BY_COLUMN,
        time_filter: "day",
        limit: 3,
      )
  end

  def zeroed_stats
    WeaponValidatable::ALL_WEAPONS.each_with_object({}) do |weapon, hash|
      shortened_name = WeaponValidatable::SHORTENED_WEAPON_NAMES[weapon]
      hash["#{shortened_name}_accuracy"] = nil
      hash["#{shortened_name}_time"] = nil
      hash["kills"] = 0
      hash["damage_dealt"] = 0
    end
  end
end
