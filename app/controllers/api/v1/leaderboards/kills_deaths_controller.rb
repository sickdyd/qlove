class Api::V1::Leaderboards::KillsDeathsController < Api::V1::BaseController
  def kills
    render_leaderboard(sort_by: KillsDeathsCalculatorService::TOTAL_KILLS_COLUMN)
  end

  def deaths
    render_leaderboard(sort_by: KillsDeathsCalculatorService::TOTAL_DEATHS_COLUMN)
  end

  def kills_deaths_ratio
    render_leaderboard(sort_by: KillsDeathsCalculatorService::KILL_DEATH_RATIO_COLUMN)
  end

  private

  def kills_deaths_params
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
    merged_params = kills_deaths_params.to_h.symbolize_keys.merge(sort_by: sort_by)

    data = KillsDeathsCalculatorService.new(**merged_params).leaderboard
    render json: { data: data }
  end
end
