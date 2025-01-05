class LeaderboardsController < ApplicationController
  before_action :validate_params

  DEFAULT_RESULTS_LIMIT = 10
  MAX_RESULTS_LIMIT = 100
  MIN_RESULTS_LIMIT = 1

  def accuracy
    render json: { data: AccuracyCalculatorService.accuracy(**leaderboard_params) }
  end

  def damage_dealt
    render json: { data: DamageCalculatorService.damage_dealt(**leaderboard_params) }
  end

  def damage_received
    render json: { data: DamageCalculatorService.damage_received(**leaderboard_params) }
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
    params_with_medals = leaderboard_params.merge(medal_types: params[:medal_types]&.split(',')&.map(&:downcase))

    render json: { data: MedalCalculatorService.medals(**params_with_medals) }
  end

  # Return the accuracy for a single player
  def stats
    unless params[:steam_id].present?
      render json: { error: 'Need to specify steam_id query parameter' }, status: :bad_request
      return
    end

    params_with_steam_id = leaderboard_params.merge(steam_id: params[:steam_id])

    render json: { data: AccuracyCalculatorService.accuracy(**params_with_steam_id) }
  end

  private

  def leaderboard_params
    {
      time_filter: params[:time_filter],
      timezone: params[:timezone],
      limit: params[:limit].to_i
    }
  end

  def validate_params
    validate_time_filter
    validate_timezone
    validate_results_limit
    validate_steam_id
  end

  def validate_time_filter
    params[:time_filter] ||= TimeFilterable::TIME_FILTERS[:day]
    unless TimeFilterable::TIME_FILTERS.values.include?(params[:time_filter])
      render json: { error: 'Invalid time_filter' }, status: :bad_request
    end
  end

  def validate_timezone
    params[:timezone] ||= TimeFilterable::DEFAULT_TIMEZONE
    unless TimeFilterable::VALID_TIMEZONES.include?(params[:timezone])
      render json: { error: 'Invalid timezone', valid_timezones: TimeFilterable::VALID_TIMEZONES }, status: :bad_request
    end
  end

  def validate_results_limit
    params[:limit] ||= DEFAULT_RESULTS_LIMIT

    valid_number = params[:limit].to_i != 0 && params[:limit].to_i.positive?
    within_range = params[:limit].to_i <= MAX_RESULTS_LIMIT || params[:limit].to_i <= MIN_RESULTS_LIMIT

    unless valid_number && within_range
      render json: { error: 'Invalid limit', valid_limit: "1 to 100" }, status: :bad_request
    end
  end

  def validate_medal_types
    return unless params[:medal_types].present?

    medal_types = params[:medal_types].split(',')
    invalid_medals = medal_types - MedalCalculatorService::ALL_MEDALS
    if invalid_medals.any?
      render json: { error: 'Invalid medal_types', valid_medal_types: MedalCalculatorService::ALL_MEDALS }, status: :bad_request
    end
  end

  def validate_steam_id
    return unless params[:steam_id].present?

    unless Player.exists?(steam_id: params[:steam_id])
      render json: { error: 'Invalid steam_id' }, status: :bad_request
    end
  end
end
