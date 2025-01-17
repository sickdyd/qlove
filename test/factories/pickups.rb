FactoryBot.define do
  factory :pickup do
    association :stat
    ammo { Faker::Number.between(from: 0, to: 50) }
    armor { Faker::Number.between(from: 0, to: 50) }
    armor_regen { Faker::Number.between(from: 0, to: 50) }
    battlesuit { Faker::Number.between(from: 0, to: 10) }
    doubler { Faker::Number.between(from: 0, to: 10) }
    flight { Faker::Number.between(from: 0, to: 10) }
    green_armor { Faker::Number.between(from: 0, to: 50) }
    guard { Faker::Number.between(from: 0, to: 10) }
    haste { Faker::Number.between(from: 0, to: 10) }
    health { Faker::Number.between(from: 0, to: 50) }
    invis { Faker::Number.between(from: 0, to: 10) }
    invulnerability { Faker::Number.between(from: 0, to: 10) }
    kamikaze { Faker::Number.between(from: 0, to: 5) }
    medkit { Faker::Number.between(from: 0, to: 20) }
    mega_health { Faker::Number.between(from: 0, to: 20) }
    other_holdable { Faker::Number.between(from: 0, to: 20) }
    other_powerup { Faker::Number.between(from: 0, to: 20) }
    portal { Faker::Number.between(from: 0, to: 10) }
    quad { Faker::Number.between(from: 0, to: 10) }
    red_armor { Faker::Number.between(from: 0, to: 50) }
    regen { Faker::Number.between(from: 0, to: 10) }
    scout { Faker::Number.between(from: 0, to: 10) }
    teleporter { Faker::Number.between(from: 0, to: 10) }
    yellow_armor { Faker::Number.between(from: 0, to: 50) }
  end
end
