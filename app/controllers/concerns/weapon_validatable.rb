module WeaponValidatable
  extend ActiveSupport::Concern

  included do
    before_action :validate_weapons
  end

  private

  def validate_weapons
    return if params[:weapons].blank?

    weapons = params[:weapons].split(',') if params[:weapons].is_a?(String) || []

    invalid_weapons = weapons - AccuracyCalculatorService::ALL_WEAPONS
    if invalid_weapons.any?
      render json: { error: 'Invalid weapons', valid_weapons: AccuracyCalculatorService::ALL_WEAPONS }, status: :bad_request
    end
  end
end
