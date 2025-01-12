class Player < ApplicationRecord
  has_many :stats, dependent: :destroy

  validates :steam_id, presence: true, uniqueness: true
end
