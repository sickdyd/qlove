class AllTimeMedalsStat < BaseMaterializedView
  self.primary_key = :id

  TOTAL_MEDALS_COLUMN = "total_medals".freeze
end
