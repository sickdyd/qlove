class Api::V1::Leaderboards::KillsDeathsController < Api::V1::BaseController
  before_action :set_model

  def kills
    render_leaderboard(sort_by: KillsDeathsStats::TOTAL_KILLS_COLUMN)
  end

  def deaths
    render_leaderboard(sort_by: KillsDeathsStats::TOTAL_DEATHS_COLUMN)
  end

  def kills_deaths_ratio
    render_leaderboard(sort_by: KillsDeathsStats::KILL_DEATH_RATIO_COLUMN)
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
      .with_defaults(COMMON_PARAMS_DEFAULTS)
  end

  def render_leaderboard(sort_by:)
    data = @model.leaderboard(**kills_deaths_params.to_h.symbolize_keys.merge(sort_by: sort_by))
    render json: { data: data }
  end

  def set_model
    @model = KillsDeathsStats.for_time_filter(kills_deaths_params[:time_filter])
  end
end
