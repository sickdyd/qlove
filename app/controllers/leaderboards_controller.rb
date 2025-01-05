class LeaderboardsController < ApplicationController
  before_action :validate_params

  def accuracies
    weapon_accuracies_for_all_players = AccuracyCalculatorService.weapon_accuracies_for_all_players(
      time_filter: params[:time_filter],
      timezone: params[:timezone]
    )
    render json: { weapon_accuracies_for_all_players: weapon_accuracies_for_all_players }
  end

  private

  def validate_params
    validate_time_filter
    validate_timezone
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
end
