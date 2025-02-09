class Stat < ApplicationRecord
  belongs_to :player

  validates :match_guid, presence: true, uniqueness: { scope: :player_id }
end
