module WeaponValidatable
  extend ActiveSupport::Concern

  ALL_WEAPONS = %w[
    bfg
    chaingun
    gauntlet
    grenade
    hmg
    lightning
    machinegun
    nailgun
    other_weapon
    plasma
    proxmine
    railgun
    rocket
    shotgun
  ].freeze

  SHORTENED_WEAPON_NAMES = {
    "bfg" => "bfg",
    "chaingun" => "cg",
    "gauntlet" => "g",
    "grenade" => "gl",
    "hmg" => "hmg",
    "lightning" => "lg",
    "machinegun" => "mg",
    "nailgun" => "ng",
    "other_weapon" => "ow",
    "plasma" => "pg",
    "proxmine" => "pm",
    "railgun" => "rg",
    "rocket" => "rl",
    "shotgun" => "sg"
  }.freeze

  included do
    before_action :validate_weapons
  end

  private

  def validate_weapons
    return if params[:weapons].blank?

    weapons = params[:weapons].split(",") if params[:weapons].is_a?(String) || []

    invalid_weapons = weapons - WeaponValidatable::ALL_WEAPONS
    if invalid_weapons.any?
      render json: { error: "Invalid weapons", valid_weapons: WeaponValidatable::ALL_WEAPONS }, status: :bad_request
    end
  end
end
