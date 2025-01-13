module ValidateMedals
  extend ActiveSupport::Concern

  included do
    before_action :validate_medals
  end

  private

  def validate_medals
    return if params[:medals].blank?

    invalid_medals = params[:medals] - MedalCalculatorService::ALL_MEDALS
    if invalid_medals.any?
      render json: { error: 'Invalid medals', valid_medals: MedalCalculatorService::ALL_MEDALS }, status: :bad_request
    end
  end
end
