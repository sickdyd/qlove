class KillsDeathsStat < BaseMaterializedView
  self.abstract_class = true

  TOTAL_KILLS_COLUMN = 'total_kills'.freeze
  TOTAL_DEATHS_COLUMN = 'total_deaths'.freeze
  KILL_DEATH_RATIO_COLUMN = 'kills_deaths_ratio'.freeze
  HEADERS = %w[player_name total_kills total_deaths kills_deaths_ratio].freeze

  class AllTimeKillsDeathsStat < KillsDeathsStat
  end

  class MonthlyKillsDeathsStat < KillsDeathsStat
  end

  class WeeklyKillsDeathsStat < KillsDeathsStat
  end

  class DailyKillsDeathsStat < KillsDeathsStat
  end

  class YearlyKillsDeathsStat < KillsDeathsStat
    def self.leaderboard(params)
      super(**params) do |query|
        query.where(year: params[:year])
      end
    end
  end
end
