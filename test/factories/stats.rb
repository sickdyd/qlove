FactoryBot.define do
  factory :stat do
    association :player
    match_guid { SecureRandom.uuid }
    aborted { false }
    blue_flag_pickups { Faker::Number.between(from: 0, to: 20) }
    deaths { Faker::Number.between(from: 0, to: 50) }
    holy_shits { Faker::Number.between(from: 0, to: 10) }
    kills { Faker::Number.between(from: 0, to: 50) }
    lose { Faker::Number.between(from: 0, to: 1) }
    max_streak { Faker::Number.between(from: 0, to: 20) }
    play_time { Faker::Number.between(from: 0, to: 10_000) } # in seconds
    quit { false }
    rank { Faker::Number.between(from: 1, to: 10) }
    red_flag_pickups { Faker::Number.between(from: 0, to: 20) }
    score { Faker::Number.between(from: 0, to: 100) }
    team { %w[blue red].sample }
    team_join_time { Faker::Number.between(from: 0, to: 10_000) } # in seconds
    team_rank { Faker::Number.between(from: 1, to: 10) }
    tied_rank { Faker::Number.between(from: 1, to: 10) }
    tied_team_rank { Faker::Number.between(from: 1, to: 10) }
    warmup { false }
    win { Faker::Number.between(from: 0, to: 1) }
    damage_dealt { Faker::Number.between(from: 1000, to: 5000) }
    damage_taken { Faker::Number.between(from: 1000, to: 5000) }
    created_at { Faker::Time.between_dates(from: 1.year.ago, to: Time.zone.now, period: :all) }
  end
end
