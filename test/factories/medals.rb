FactoryBot.define do
  factory :medal do
    association :stat
    accuracy { Faker::Number.between(from: 0, to: 100) }
    assists { Faker::Number.between(from: 0, to: 20) }
    captures { Faker::Number.between(from: 0, to: 10) }
    combokill { Faker::Number.between(from: 0, to: 10) }
    defends { Faker::Number.between(from: 0, to: 20) }
    excellent { Faker::Number.between(from: 0, to: 50) }
    firstfrag { Faker::Number.between(from: 0, to: 10) }
    headshot { Faker::Number.between(from: 0, to: 50) }
    humiliation { Faker::Number.between(from: 0, to: 5) }
    impressive { Faker::Number.between(from: 0, to: 50) }
    midair { Faker::Number.between(from: 0, to: 10) }
    perfect { Faker::Number.between(from: 0, to: 10) }
    perforated { Faker::Number.between(from: 0, to: 5) }
    quadgod { Faker::Number.between(from: 0, to: 5) }
    rampage { Faker::Number.between(from: 0, to: 10) }
    revenge { Faker::Number.between(from: 0, to: 10) }
  end
end
