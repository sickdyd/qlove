class KillsDeathsStats < BaseMaterializedView
  self.abstract_class = true

  TOTAL_KILLS_COLUMN = 'total_kills'.freeze
  TOTAL_DEATHS_COLUMN = 'total_deaths'.freeze
  KILL_DEATH_RATIO_COLUMN = 'kills_deaths_ratio'.freeze
  HEADERS = %w[player_name total_damage_dealt total_damage_taken].freeze
end
