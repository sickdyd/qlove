class Api::V1::Leaderboards::WinsLossesController < ApplicationController
  include ValidateCommonParams

  def wins
    render json: { data: WinLoseCalculatorService.wins(wins_losses_params.to_h.symbolize_keys) }
  end

  def losses
    render json: { data: WinLoseCalculatorService.losses(wins_losses_params.to_h.symbolize_keys) }
  end

  private

  def wins_losses_params
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
