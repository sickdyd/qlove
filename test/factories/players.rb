FactoryBot.define do
  factory :player do
    name { Faker::Name.name }
    steam_id { Faker::Alphanumeric.alpha(number: 8) }
  end
end
