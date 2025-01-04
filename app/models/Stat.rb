class Stat < ApplicationRecord
  belongs_to :player
  has_many :medals, dependent: :destroy
  has_many :pickups, dependent: :destroy
  has_many :weapons, dependent: :destroy
end
