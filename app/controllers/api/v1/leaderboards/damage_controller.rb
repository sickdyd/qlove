class Api::V1::Leaderboards::DamageController < Api::V1::BaseController
  def damage_dealt
    render_leaderboard(sort_by: DamageCalculatorService::TOTAL_DAMAGE_DEALT_COLUMN)
  end

  def damage_taken
    render_leaderboard(sort_by: DamageCalculatorService::TOTAL_DAMAGE_TAKEN_COLUMN)
  end

  private

  def damage_params
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
    merged_params = damage_params.to_h.symbolize_keys.merge(sort_by: sort_by)

    data = DamageCalculatorService.new(**merged_params).leaderboard
    render json: { data: data }
  end
end
