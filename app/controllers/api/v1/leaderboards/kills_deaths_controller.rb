class Api::V1::Leaderboards::KillsDeathsController < ApplicationController
  include ValidateCommonParams

  def kills
    render json: { data: KillDeathCalculatorService.kills(kills_deaths_params.to_h.symbolize_keys) }
  end

  def deaths
    render json: { data: KillDeathCalculatorService.deaths(kills_deaths_params.to_h.symbolize_keys) }
  end

  # TODO: Implement the kill_death_ratio method
  def kills_deaths_ratio
    render json: { data: KillDeathCalculatorService.kill_death_ratio(kills_deaths_params.to_h.symbolize_keys) }
  end

  private

  def kills_deaths_params
    params
      .permit(
        :time_filter,
        :timezone,
        :limit,
        :formatted_table,
        :year,
      )
      .with_defaults(CommonParamsDefaults::DEFAULTS)
  end
end
