class Api::V1::BaseController < ApplicationController
  before_action :validate_time_filter
  before_action :validate_timezone
  before_action :validate_limit
  before_action :validate_formatted_table

  DEFAULT_RESULTS_LIMIT = 10
  MAX_RESULTS_LIMIT = 30
  MIN_RESULTS_LIMIT = 1
  EARLIEST_YEAR = 2010

  COMMON_PARAMS_DEFAULTS = {
    time_filter: "all_time",
    timezone: TimeFilterable::DEFAULT_TIMEZONE,
    limit: DEFAULT_RESULTS_LIMIT,
    formatted_table: false
  }

  private

  def validate_time_filter
    return if params[:time_filter].blank?

    unless  TimeFilterable::TIME_FILTERS.include?(params[:time_filter])
      render json: { error: "Invalid time_filter" }, status: :bad_request
    end
  end

  def validate_timezone
    return if params[:timezone].blank?

    unless TimeFilterable::VALID_TIMEZONES.include?(params[:timezone])
      render json: { error: TimeFilterable.invalid_timezone_error_message }, status: :bad_request
    end
  end

  def validate_limit
    return if params[:limit].blank?

    unless params[:limit].to_i.between?(MIN_RESULTS_LIMIT, MAX_RESULTS_LIMIT)
      render json: { error: "Invalid limit", valid_limits: "#{MIN_RESULTS_LIMIT} to #{MAX_RESULTS_LIMIT}" }, status: :bad_request
    end
  end

  def validate_formatted_table
    return if params[:formatted_table].blank?

    unless [ "true", "false" ].include?(params[:formatted_table])
      render json: { error: "Invalid formatted_table", valid_values: "true, false" }, status: :bad_request
    end

    params[:formatted_table] = ActiveRecord::Type::Boolean.new.deserialize(params[:formatted_table])
  end
end
