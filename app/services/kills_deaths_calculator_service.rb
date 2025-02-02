class KillsDeathsCalculatorService < BaseCalculatorService
  TOTAL_KILLS_COLUMN = "total_kills".freeze
  TOTAL_DEATHS_COLUMN = "total_deaths".freeze
  KILL_DEATH_RATIO_COLUMN = "kill_death_ratio".freeze

  HEADERS = [ "name", TOTAL_KILLS_COLUMN, TOTAL_DEATHS_COLUMN, KILL_DEATH_RATIO_COLUMN ]

  def leaderboard
    super do |query|
      query
        .select("
          players.id,
          players.steam_id,
          players.name,
          SUM(stats.kills) as #{TOTAL_KILLS_COLUMN},
          SUM(stats.deaths) as #{TOTAL_DEATHS_COLUMN},
          ROUND(SUM(stats.kills) / NULLIF(SUM(stats.deaths), 0), 2) as #{KILL_DEATH_RATIO_COLUMN}
        ")
    end
  end
end
