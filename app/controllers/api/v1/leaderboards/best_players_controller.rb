class Api::V1::Leaderboards::BestPlayersController < ApplicationController
  include ValidateCommonParams

  def show
    render json: { data: BestPlayerCalculatorService.best_players(**best_players_params.to_h.symbolize_keys) }
  end

  private

  def best_players_params
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
