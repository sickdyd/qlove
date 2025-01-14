class Api::V1::Leaderboards::MedalsController < Api::V1::BaseController
  before_action :validate_medals

  def index
    render json: { data: MedalCalculatorService.medals(medals_params.to_h.symbolize_keys) }
  end

  private

  def medals_params
    params
      .permit(
        :time_filter,
        :timezone,
        :limit,
        :formatted_table,
        :year,
        :medals,
      )
      .with_defaults(
        COMMON_PARAMS_DEFAULTS
          .merge(medals: MedalCalculatorService::ALL_MEDALS)
      )
  end

  def validate_medals
    return if params[:medals].blank?

    invalid_medals = params[:medals] - MedalCalculatorService::ALL_MEDALS
    if invalid_medals.any?
      render json: { error: 'Invalid medals', valid_medals: MedalCalculatorService::ALL_MEDALS }, status: :bad_request
    end
  end
end
