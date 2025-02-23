class Api::V1::Leaderboards::MedalsController < Api::V1::BaseController
  include MedalValidatable

  def index
    render_leaderboard(sort_by: MedalsCalculatorService::TOTAL_MEDALS_COLUMN)
  end

  private

  def medals_array
    return MedalValidatable::ALL_MEDALS if params[:medals].blank?

    params[:medals].split(",").map(&:strip)
  end

  def medals_params
    params
      .permit(
        :time_filter,
        :timezone,
        :limit,
        :formatted_table,
        :medals,
      )
      .with_defaults(
        COMMON_PARAMS_DEFAULTS
          .merge(medals: MedalValidatable::ALL_MEDALS.join(",")),
      )
  end

  def render_leaderboard(sort_by:)
    merged_params = medals_params.to_h.symbolize_keys.merge(
        medals: medals_array,
        sort_by: sort_by
      )

    data = MedalsCalculatorService.new(**merged_params).leaderboard
    render json: { data: data }
  end
end
