class Api::V1::Leaderboards::DamageController < ApplicationController
  include ValidateCommonParams

  def damage_dealt
    render json: { data: DamageStats.leaderboard(
      **damage_params
        .to_h
        .symbolize_keys
        .merge(sort_by: DamageStats::TOTAL_DAMAGE_DEALT_COLUMN)
      )
    }
  end

  def damage_taken
    render json: { data: DamageStats.leaderboard(
      **damage_params
        .to_h
        .symbolize_keys
        .merge(sort_by: DamageStats::TOTAL_DAMAGE_TAKEN_COLUMN)
      )
    }
  end

  private

  def damage_params
    params
      .permit(
        :time_filter,
        :timezone,
        :limit,
        :formatted_table,
        :year,
      )
      .with_defaults(CommonParamsDefaults::DEFAULTS)
  end
end
