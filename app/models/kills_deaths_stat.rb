class KillsDeathsStat < BaseMaterializedView
  self.primary_key = :player_id

  TOTAL_KILLS_COLUMN = "total_kills".freeze
  TOTAL_DEATHS_COLUMN = "total_deaths".freeze
  KILL_DEATH_RATIO_COLUMN = "kills_deaths_ratio".freeze

  HEADERS = %w[player_name total_kills total_deaths kills_deaths_ratio].freeze
end
