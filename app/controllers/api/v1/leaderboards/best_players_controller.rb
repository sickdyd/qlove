class Api::V1::Leaderboards::BestPlayersController < Api::V1::BaseController
  def show
    merged_params = best_players_params.to_h.symbolize_keys.merge(
      sort_by: BestPlayersCalculatorService::SORT_BY_COLUMN
    )

    data = BestPlayersCalculatorService.new(**merged_params).leaderboard
    render json: { data: data }
  end

  private

  def best_players_params
    params
      .permit(
        :time_filter,
        :timezone,
        :limit,
        :formatted_table,
      )
      .with_defaults(COMMON_PARAMS_DEFAULTS)
  end
end
