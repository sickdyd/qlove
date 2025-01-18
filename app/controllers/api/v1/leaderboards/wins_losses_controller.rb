class Api::V1::Leaderboards::WinsLossesController < Api::V1::BaseController
  before_action :set_model

  def wins
    render_leaderboard(sort_by: WinsLossesStats::TOTAL_WINS_COLUMN)
  end

  def losses
    render_leaderboard(sort_by: WinsLossesStats::TOTAL_LOSSES_COLUMN)
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
      .with_defaults(COMMON_PARAMS_DEFAULTS)
  end

  def render_leaderboard(sort_by:)
    data = @model.leaderboard(**wins_losses_params.to_h.symbolize_keys.merge(sort_by: sort_by))
    render json: { data: data }
  end

  def set_model
    @model = WinsLossesStats.model_for_time_filter(wins_losses_params[:time_filter])
  end
end
