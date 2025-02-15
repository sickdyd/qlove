class ZmqSubscriber < ApplicationRecord
  validates :username, :host, :port, presence: true
  encrypts :password
end
