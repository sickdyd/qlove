class Api::V1::Leaderboards::WinsLossesController < Api::V1::BaseController
  def wins
    render_leaderboard(sort_by: WinsLossesStat::TOTAL_WINS_COLUMN)
  end

  def losses
    render_leaderboard(sort_by: WinsLossesStat::TOTAL_LOSSES_COLUMN)
  end

  private

  def wins_losses_params
    params
      .permit(
        :time_filter,
        :timezone,
        :limit,
        :formatted_table,
      )
      .with_defaults(COMMON_PARAMS_DEFAULTS)
  end

  def render_leaderboard(sort_by:)
    data = WinsLossesStat.leaderboard(**wins_losses_params.to_h.symbolize_keys.merge(sort_by: sort_by))
    render json: { data: data }
  end
end
