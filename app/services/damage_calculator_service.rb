class DamageCalculatorService < BaseCalculatorService
  TOTAL_DAMAGE_DEALT_COLUMN = "total_damage_dealt"
  TOTAL_DAMAGE_TAKEN_COLUMN = "total_damage_taken"

  def leaderboard
    super do |query|
      query
        .select("
          players.id,
          players.steam_id,
          players.name,
          SUM(stats.damage_dealt) as total_damage_dealt,
          SUM(stats.damage_taken) as total_damage_taken
        ")
    end
  end

  private

  def headers
    [ "name", "damage_dealt", "damage_taken" ]
  end

  def table_title
    "#{sort_by.titleize} for the #{time_filter}"
  end
end
