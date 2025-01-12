require 'benchmark'

module EventHandlers
  class RefreshMaterializedViewsHandler
    def self.handle(data)
      Rails.logger.debug "Refreshing all materialized views"

      DamageCalculatorDay.refresh
      DamageCalculatorWeek.refresh
      DamageCalculatorMonth.refresh
      DamageCalculatorYear.refresh
      DamageCalculatorAllTime.refresh

      Rails.logger.debug("Players count: #{Player.count}")
      Rails.logger.debug("Stats count: #{Stat.count}")
      Rails.logger.debug("Weapons count: #{Weapon.count}")

      time_filter = 'month'
      limit = 10

      Benchmark.bm do |x|
        x.report("Materialized View:") do
          DamageCalculatorAllTime
            .order(total_damage_dealt: :desc)
            .limit(limit)
            .to_a
        end

        x.report("Ruby Query:") do
          stats = Stat
            .joins(:player)
            .select(
              'players.name AS player_name',
              'players.steam_id AS steam_id',
              'SUM(stats.damage_dealt) AS total_damage_dealt',
              'SUM(stats.damage_taken) AS total_damage_taken'
            )
            .group('players.id', 'players.name', 'players.steam_id')
            .order('SUM(stats.damage_dealt) DESC')
            .limit(limit)
            .to_a

          stats.map do |stat|
            {
              player_name: stat.player_name,
              steam_id: stat.steam_id,
              total_damage_dealt: stat.total_damage_dealt.to_i,
              total_damage_taken: stat.total_damage_taken.to_i
            }
          end
        end
      end
    end
  end
end
