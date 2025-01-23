class DamageStat < BaseMaterializedView
  self.primary_key = :player_id

  TOTAL_DAMAGE_DEALT_COLUMN = 'total_damage_dealt'.freeze
  TOTAL_DAMAGE_TAKEN_COLUMN = 'total_damage_taken'.freeze

  HEADERS = %w[player_name total_damage_dealt total_damage_taken].freeze
end
