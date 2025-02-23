class Api::V1::Leaderboards::AccuracyController < Api::V1::BaseController
  include WeaponValidatable

  before_action :validate_steam_id, only: :show

  def index
    render_leaderboard
  end

  def show
    render_leaderboard
  end

  private

  def accuracy_params
    params
      .permit(
        :time_filter,
        :timezone,
        :limit,
        :formatted_table,
        :weapons,
        :steam_id,
      )
      .with_defaults(COMMON_PARAMS_DEFAULTS)
  end

  private

  def weapons_array
    return WeaponValidatable::ALL_WEAPONS if params[:weapons].blank?

    params[:weapons].split(",").map(&:strip)
  end

  def validate_steam_id
    unless params[:steam_id].present?
      render json: { error: "Missing steam_id" }, status: :bad_request
      return
    end

    unless Player.exists?(steam_id: params[:steam_id])
      render json: { error: "Invalid steam_id" }, status: :bad_request
    end
  end

  def render_leaderboard
    merged_params = accuracy_params.to_h.symbolize_keys.merge(
      weapons: weapons_array,
      sort_by: AccuracyCalculatorService::AVERAGE_ACCURACY_COLUMN
    )

    data = AccuracyCalculatorService.new(**merged_params).leaderboard
    render json: { data: data }
  end
end
