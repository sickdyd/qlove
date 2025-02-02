class DamageCalculatorService < BaseCalculatorService
  TOTAL_DAMAGE_DEALT_COLUMN = "total_damage_dealt".freeze
  TOTAL_DAMAGE_TAKEN_COLUMN = "total_damage_taken".freeze

  HEADERS = [ "name", TOTAL_DAMAGE_DEALT_COLUMN, TOTAL_DAMAGE_TAKEN_COLUMN ]

  def leaderboard
    super do |query|
      query
        .select("
          players.id,
          players.steam_id,
          players.name,
          SUM(stats.damage_dealt) as #{TOTAL_DAMAGE_DEALT_COLUMN},
          SUM(stats.damage_taken) as #{TOTAL_DAMAGE_TAKEN_COLUMN}
        ")
    end
  end
end
