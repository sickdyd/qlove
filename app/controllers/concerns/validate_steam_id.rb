module ValidateSteamId
  extend ActiveSupport::Concern

  included do
    before_action :validate_steam_id
  end

  private

  def validate_steam_id
    unless params[:steam_id].present?
      render json: { error: 'Missing steam_id' }, status: :bad_request
      return
    end

    unless Player.exists?(steam_id: params[:steam_id])
      render json: { error: 'Invalid steam_id' }, status: :bad_request
    end
  end
end
