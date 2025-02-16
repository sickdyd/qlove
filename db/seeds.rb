# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create at least one ZmqSubscriber getting values from env vars
raise "Missing required environment variable ZMQ_SUBSCRIBER_USERNAME" unless ENV["ZMQ_SUBSCRIBER_USERNAME"]
raise "Missing required environment variable ZMQ_SUBSCRIBER_PASSWORD" unless ENV["ZMQ_SUBSCRIBER_PASSWORD"]
raise "Missing required environment variable ZMQ_SUBSCRIBER_HOST" unless ENV["ZMQ_SUBSCRIBER_HOST"]
raise "Missing required environment variable ZMQ_SUBSCRIBER_PORT" unless ENV["ZMQ_SUBSCRIBER_PORT"]

ZmqSubscriber.find_or_create_by!(
  username: ENV["ZMQ_SUBSCRIBER_USERNAME"],
  password: ENV["ZMQ_SUBSCRIBER_PASSWORD"],
  host: ENV["ZMQ_SUBSCRIBER_HOST"],
  port: ENV["ZMQ_SUBSCRIBER_PORT"]
)
