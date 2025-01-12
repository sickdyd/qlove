class Player < ApplicationRecord
  has_many :stats, dependent: :destroy

  validate :steam_id, presence: true, uniqueness: true
end
