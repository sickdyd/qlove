FactoryBot.define do
  factory :weapon do
    association :stat,
    name { "weapon_name" }
    deaths { Faker::Number.between(from: 0, to: 50) }
    damage_given { Faker::Number.between(from: 0, to: 5000) }
    damage_received { Faker::Number.between(from: 0, to: 5000) }
    hits { Faker::Number.between(from: 0, to: 100) }
    kills { Faker::Number.between(from: 0, to: 50) }
    pickups { Faker::Number.between(from: 0, to: 20) }
    shots { Faker::Number.between(from: 0, to: 200) }
    time { Faker::Number.between(from: 0, to: 10_000) }
  end
end
