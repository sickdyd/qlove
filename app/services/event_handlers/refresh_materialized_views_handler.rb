require "benchmark"

module EventHandlers
  class RefreshMaterializedViewsHandler
    def self.handle(data)
      Rails.logger.debug "Refreshing all materialized views"

      AllTimeDamageStat.refresh
      AllTimeKillsDeathsStat.refresh
      AllTimeMedalsStat.refresh
      AllTimeWinsLossesStat.refresh
      AllTimePlayTimeStat.refresh

      limit = 1000

      Benchmark.bm do |x|
        x.report("Materialized View:") do
          AllTimeDamageStat
            .limit(limit)
            .to_a
        end

        x.report("Ruby Query:") do
          stats = Stat
            .joins(:player)
            .select(
              "players.name AS player_name",
              "players.steam_id AS steam_id",
              "SUM(damage_dealt) AS total_damage_dealt",
              "SUM(damage_taken) AS total_damage_taken"
            )
            .group("players.id", "players.name", "players.steam_id")
            .order("SUM(stats.damage_dealt) DESC")
            .limit(limit)
            .to_a
        end
      end
    end
  end
end
