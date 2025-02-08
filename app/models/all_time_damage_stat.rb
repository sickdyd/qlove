class AllTimeDamageStat < BaseMaterializedView
  self.primary_key = :id

  TOTAL_DAMAGE_DEALT_COLUMN = "total_damage_dealt".freeze
  TOTAL_DAMAGE_TAKEN_COLUMN = "total_damage_taken".freeze
end
