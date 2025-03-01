class AllTimeMedalsStat < BaseMaterializedView
  self.primary_key = :id

  belongs_to :player, foreign_key: :player_id, primary_key: :id

  TOTAL_MEDALS_COLUMN = "total_medals".freeze
end
