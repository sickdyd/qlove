class Api::V1::LeaderboardsController < ApplicationController
  before_action :validate_time_filter
  before_action :validate_timezone
  before_action :validate_limit, only: %i[accuracy damage_dealt damage_taken kills deaths wins losses best]
  before_action :validate_medals, only: :medals
  before_action :validate_weapons, only: %i[accuracy stats]
  before_action :validate_steam_id, only: :stats

  DEFAULT_RESULTS_LIMIT = 10
  MAX_RESULTS_LIMIT = 100
  MIN_RESULTS_LIMIT = 1

  def accuracy
    render json: { data: AccuracyCalculatorService.accuracy(**(leaderboard_params.merge(weapons: @weapons))) }
  end

  def damage_dealt
    render json: { data: DamageCalculatorService.damage_dealt(**leaderboard_params) }
  end

  def damage_taken
    render json: { data: DamageCalculatorService.damage_taken(**leaderboard_params) }
  end

  def kills
    render json: { data: KillDeathCalculatorService.kills(**leaderboard_params) }
  end

  def deaths
    render json: { data: KillDeathCalculatorService.deaths(**leaderboard_params) }
  end

  def wins
    render json: { data: WinLoseCalculatorService.wins(**leaderboard_params) }
  end

  def losses
    render json: { data: WinLoseCalculatorService.losses(**leaderboard_params) }
  end

  def best
    render json: { data: BestCalculatorService.best_players(**leaderboard_params) }
  end

  def medals
    render json: { data: MedalCalculatorService.medals(**(leaderboard_params.merge(medals: @medals))) }
  end

  def stats
    render json: { data: AccuracyCalculatorService.accuracy(**leaderboard_params.merge(steam_id: params[:steam_id], weapons: @weapons)) }
  end

  private

  def leaderboard_params
    {
      time_filter: @time_filter,
      timezone: @timezone,
      limit: @limit || MIN_RESULTS_LIMIT
    }
  end

  def validate_time_filter
    @time_filter = params[:time_filter].present? ? params[:time_filter] : TIME_FILTERS.values.first

    unless TimeFilterable::TIME_FILTERS.values.include?(@time_filter)
      render json: { error: 'Invalid time_filter' }, status: :bad_request
    end
  end

  def validate_timezone
    @timezone = params[:timezone].present? ? params[:timezone] : TimeFilterable::DEFAULT_TIMEZONE

    unless TimeFilterable::VALID_TIMEZONES.include?(@timezone)
      render json: { error: 'Invalid timezone', valid_timezones: TimeFilterable::VALID_TIMEZONES }, status: :bad_request
    end
  end

  def validate_limit
    @limit = params[:limit].to_i

    unless @limit.between?(MIN_RESULTS_LIMIT, MAX_RESULTS_LIMIT)
      render json: { error: 'Invalid limit', valid_limits: "#{MIN_RESULTS_LIMIT} to #{MAX_RESULTS_LIMIT}" }, status: :bad_request
      return
    end
  end

  def validate_medals
    @medals = params[:medals].present? ? params[:medals].split(',') : MedalCalculatorService::ALL_MEDALS

    invalid_medals = @medals - MedalCalculatorService::ALL_MEDALS
    if invalid_medals.any?
      render json: { error: 'Invalid medals', valid_medals: MedalCalculatorService::ALL_MEDALS }, status: :bad_request
    end
  end

  def validate_weapons
    @weapons = params[:weapons].present? ? params[:weapons].split(',') : AccuracyCalculatorService::ALL_WEAPONS

    invalid_weapons = @weapons - AccuracyCalculatorService::ALL_WEAPONS
    if invalid_weapons.any?
      render json: { error: 'Invalid weapons', valid_weapons: AccuracyCalculatorService::ALL_WEAPONS }, status: :bad_request
    end
  end

  def validate_steam_id
    @steam_id = params[:steam_id]

    unless params[:steam_id].present?
      render json: { error: 'Missing steam_id' }, status: :bad_request
    end

    unless Player.exists?(steam_id: params[:steam_id])
      render json: { error: 'Invalid steam_id' }, status: :bad_request
    end
  end
end
