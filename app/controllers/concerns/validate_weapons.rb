module ValidateWeapons
  extend ActiveSupport::Concern

  included do
    before_action :validate_weapons
  end

  private

  def validate_weapons
    return if params[:weapons].blank?

    invalid_weapons = params[:weapons] - AccuracyCalculatorService::ALL_WEAPONS
    if invalid_weapons.any?
      render json: { error: 'Invalid weapons', valid_weapons: AccuracyCalculatorService::ALL_WEAPONS }, status: :bad_request
    end
  end
end
