class Api::V1::Leaderboards::AccuracyController < ApplicationController
  include ValidateCommonParams
  include ValidateWeapons

  def show
    render json: { data: AccuracyCalculatorService.calculate_accuracy(**accuracy_params.to_h.symbolize_keys) }
  end

  private

  def accuracy_params
    params
      .permit(
        :time_filter,
        :timezone,
        :limit,
        :formatted_table,
        :year,
        :weapons,
      )
      .with_defaults(
        CommonParamsDefaults::DEFAULTS
          .merge(weapons: AccuracyCalculatorService::ALL_WEAPONS)
      )
  end
end
