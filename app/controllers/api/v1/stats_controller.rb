class Api::V1::StatsController < ApplicationController
  include ValidateCommonParams
  include ValidateWeapons
  include ValidateSteamId

  def show
    render json: { data: AccuracyCalculatorService.accuracy(**stats_params.to_h.symbolize_keys) }
  end

  private

  def stats_params
    params
      .permit(
        :time_filter,
        :timezone,
        :limit,
        :formatted_table,
        :year,
        :steam_id,
        :weapons,
      )
      .with_defaults(
        CommonParamsDefaults::DEFAULTS
          .merge(weapons: AccuracyCalculatorService::ALL_WEAPONS)
      )
  end
end
