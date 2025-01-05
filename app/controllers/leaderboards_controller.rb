class LeaderboardsController < ApplicationController
  before_action :validate_params

  DEFAULT_RESULTS_LIMIT = 10
  MAX_RESULTS_LIMIT = 100
  MIN_RESULTS_LIMIT = 1

  def accuracy
    weapons = params[:weapons]&.split(',')&.map(&:downcase)
    params_with_weapons = leaderboard_params.merge(weapons: weapons.present? ? weapons : AccuracyCalculatorService::ALL_WEAPONS)

    render json: { data: AccuracyCalculatorService.accuracy(**params_with_weapons) }
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
    medals = params[:medals]&.split(',')
    params_with_medals = leaderboard_params.merge(medals: medals.present? ? medals : MedalCalculatorService::ALL_MEDALS)

    render json: { data: MedalCalculatorService.medals(**params_with_medals) }
  end

  # Return the accuracy for a single player
  def stats
    unless params[:steam_id].present?
      render json: { error: 'Need to specify steam_id query parameter' }, status: :bad_request
      return
    end

    weapons = params[:weapons]&.split(',')&.map(&:downcase)
    params_with_additional_data = leaderboard_params.merge(
      steam_id: params[:steam_id],
      weapons: weapons.present? ? weapons : AccuracyCalculatorService::ALL_WEAPONS
    )

    render json: { data: AccuracyCalculatorService.accuracy(**params_with_additional_data) }
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
    validate_medals
    validate_steam_id
    validate_weapons
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

  def validate_medals
    return unless params[:medals].present?

    medals = params[:medals].split(',')
    invalid_medals = medals - MedalCalculatorService::ALL_MEDALS
    if invalid_medals.any?
      render json: { error: 'Invalid medals', valid_medals: MedalCalculatorService::ALL_MEDALS }, status: :bad_request
    end
  end

  def validate_steam_id
    return unless params[:steam_id].present?

    unless Player.exists?(steam_id: params[:steam_id])
      render json: { error: 'Invalid steam_id' }, status: :bad_request
    end
  end

  def validate_weapons
    return unless params[:weapons].present?

    weapons = params[:weapons].split(',')
    invalid_weapons = weapons - AccuracyCalculatorService::ALL_WEAPONS
    if invalid_weapons.any?
      render json: { error: 'Invalid weapons', valid_weapons: AccuracyCalculatorService::ALL_WEAPONS }, status: :bad_request
    end
  end
end
