class Api::V1::Leaderboards::MedalsController < ApplicationController
  include ValidateCommonParams
  include ValidateMedalsParams

  def medals
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
        CommonParamsDefaults::DEFAULTS
          .merge(medals: MedalCalculatorService::ALL_MEDALS)
      )
  end
end
