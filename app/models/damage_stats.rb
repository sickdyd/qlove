class DamageStats < BaseMaterializedView
  self.abstract_class = true

  TOTAL_DAMAGE_DEALT_COLUMN = 'total_damage_dealt'.freeze
  TOTAL_DAMAGE_TAKEN_COLUMN = 'total_damage_taken'.freeze
  HEADERS = %w[player_name total_damage_dealt total_damage_taken].freeze
end
