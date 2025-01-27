module MedalValidatable
  extend ActiveSupport::Concern

  ALL_MEDALS = %w[
    accuracy
    assists
    captures
    combokill
    defends
    excellent
    firstfrag
    headshot
    humiliation
    impressive
    midair
    perfect
    perforated
    quadgod
    rampage
    revenge
  ].freeze

  included do
    before_action :validate_medals
  end

  private

  def validate_medals
    return if medals_params[:medals].blank?

    unless (medals_params[:medals].to_s.split(",") - ALL_MEDALS).empty?
      render json: { error: "Invalid medals", valid_medals: ALL_MEDALS }, status: :bad_request
    end
  end
end
