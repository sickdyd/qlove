class AllTimeWinsLossesStat < BaseMaterializedView
  self.primary_key = :id

  belongs_to :player, foreign_key: :player_id, primary_key: :id
end
