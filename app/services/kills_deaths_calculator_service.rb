class KillsDeathsCalculatorService < BaseCalculatorService
  TOTAL_KILLS_COLUMN = "total_kills"
  TOTAL_DEATHS_COLUMN = "total_deaths"
  KILL_DEATH_RATIO_COLUMN = "kill_death_ratio"

  HEADERS = [ "name", TOTAL_KILLS_COLUMN, TOTAL_DEATHS_COLUMN, KILL_DEATH_RATIO_COLUMN ]

  def leaderboard
    super do |query|
      query
        .select("
          players.id,
          players.steam_id,
          players.name,
          SUM(stats.kills) as total_kills,
          SUM(stats.deaths) as total_deaths,
          ROUND(SUM(stats.kills) / NULLIF(SUM(stats.deaths), 0), 2) as kill_death_ratio
        ")
    end
  end
end
