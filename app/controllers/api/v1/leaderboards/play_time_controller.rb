class Api::V1::Leaderboards::PlayTimeController < Api::V1::BaseController
  def play_time
    render_leaderboard(sort_by: PlayTimeCalculatorService::TOTAL_PLAY_TIME_COLUMN)
  end

  private

  def time_played_params
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
    merged_params = time_played_params.to_h.symbolize_keys.merge(sort_by: sort_by)

    data = PlayTimeCalculatorService.new(**merged_params).leaderboard
    render json: { data: data }
  end
end
