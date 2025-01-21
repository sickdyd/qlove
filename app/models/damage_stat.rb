class DamageStat < BaseMaterializedView
  self.abstract_class = true

  TOTAL_DAMAGE_DEALT_COLUMN = 'total_damage_dealt'.freeze
  TOTAL_DAMAGE_TAKEN_COLUMN = 'total_damage_taken'.freeze
  HEADERS = %w[player_name total_damage_dealt total_damage_taken].freeze

  class AllTimeDamageStat < DamageStat
  end

  class MonthlyDamageStat < DamageStat
  end

  class WeeklyDamageStat < DamageStat
  end

  class DailyDamageStat < DamageStat
  end

  class YearlyDamageStat < DamageStat
    def self.leaderboard(params)
      super(**params) do |query|
        query.where(year: params[:year])
      end
    end
  end
end
