class Player < ApplicationRecord
  has_many :stats, dependent: :destroy
end
