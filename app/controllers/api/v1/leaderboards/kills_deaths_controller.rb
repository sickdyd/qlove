class Api::V1::Leaderboards::KillsDeathsController < Api::V1::BaseController
  def kills
    render json: { data: KillsDeathsStats.kills_and_deaths(**kills_deaths_params.to_h.symbolize_keys.merge(sort_by: KillsDeathsStats::TOTAL_KILLS_COLUMN)) }
  end

  def deaths
    render json: { data: KillsDeathsStats.kills_and_deaths(**kills_deaths_params.to_h.symbolize_keys.merge(sort_by: KillsDeathsStats::TOTAL_DEATHS_COLUMN)) }
  end

  def kills_deaths_ratio
    render json: { data: KillsDeathsStats.kills_and_deaths(**kills_deaths_params.to_h.symbolize_keys.merge(sort_by: KillsDeathsStats::KILL_DEATH_RATIO_COLUMN)) }
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
end
