class LeaderboardsController < ApplicationController
  before_action :validate_params

  DEFAULT_RESULTS_LIMIT = 10
  MAX_RESULTS_LIMIT = 100
  MIN_RESULTS_LIMIT = 1

  def accuracies
    weapon_accuracies_for_all_players = AccuracyCalculatorService.weapon_accuracies_for_all_players(
      time_filter: params[:time_filter],
      timezone: params[:timezone],
      limit: params[:limit].to_i
    )
    render json: { weapon_accuracies_for_all_players: weapon_accuracies_for_all_players }
  end

  private

  def validate_params
    validate_time_filter
    validate_timezone
    validate_results_limit
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
    unless params[:limit].to_i.positive? && (params[:limit].to_i <= MAX_RESULTS_LIMIT || params[:limit].to_i <= MIN_RESULTS_LIMIT)
      render json: { error: 'Invalid limit', valid_limit: "1 to 100" }, status: :bad_request
    end
  end
end
