class Api::V1::Leaderboards::MedalsController < Api::V1::BaseController
  before_action :validate_medals
  before_action :set_model

  def index
    render_leaderboard(sort_by: MedalsStat::TOTAL_MEDALS_COLUMN)
  end

  private

  def medals_params
    params
      .permit(
        :time_filter,
        :timezone,
        :limit,
        :formatted_table,
        :year,
        :medals,
      )
      .with_defaults(
        COMMON_PARAMS_DEFAULTS
          .merge(medals: MedalsStat::ALL_MEDALS.join(',')),
      )
  end

  def validate_medals
    return if medals_params[:medals].blank?

    unless (medals_params[:medals].to_s.split(',') - MedalsStat::ALL_MEDALS).empty?
      render json: { error: 'Invalid medals', valid_medals: MedalsStat::ALL_MEDALS }, status: :bad_request
    end
  end

  def render_leaderboard(sort_by:)
    medals = medals_params[:medals].split(',')
    data = @model.leaderboard(**medals_params.to_h.symbolize_keys.merge(sort_by: sort_by, medals: medals))
    render json: { data: data }
  end

  def set_model
    @model = MedalsStat.model_for_time_filter(medals_params[:time_filter])
  end
end
