class AllTimeKillsDeathsStat < BaseMaterializedView
  self.primary_key = :id

  belongs_to :player, foreign_key: :player_id, primary_key: :id

  TOTAL_KILLS_COLUMN = "total_kills".freeze
  TOTAL_DEATHS_COLUMN = "total_deaths".freeze
  KILL_DEATH_RATIO_COLUMN = "kills_deaths_ratio".freeze
end
