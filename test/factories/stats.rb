FactoryBot.define do
  factory :stat do
    association :player
    match_guid { SecureRandom.uuid }

    deaths { Faker::Number.between(from: 0, to: 50) }
    kills { Faker::Number.between(from: 0, to: 50) }
    lose { Faker::Number.between(from: 0, to: 1) }
    play_time { Faker::Number.between(from: 0, to: 10_000) } # in seconds
    quit { Faker::Number.between(from: 0, to: 1) }
    rank { Faker::Number.between(from: 1, to: 10) }
    score { Faker::Number.between(from: 0, to: 100) }
    win { Faker::Number.between(from: 0, to: 1) }
    damage_dealt { Faker::Number.between(from: 1000, to: 5000) }
    damage_taken { Faker::Number.between(from: 1000, to: 5000) }

    # Medals Data
    accuracy { Faker::Number.between(from: 0, to: 100) }
    assists { Faker::Number.between(from: 0, to: 50) }
    captures { Faker::Number.between(from: 0, to: 20) }
    combokill { Faker::Number.between(from: 0, to: 10) }
    defends { Faker::Number.between(from: 0, to: 20) }
    excellent { Faker::Number.between(from: 0, to: 10) }
    firstfrag { Faker::Number.between(from: 0, to: 5) }
    headshot { Faker::Number.between(from: 0, to: 20) }
    humiliation { Faker::Number.between(from: 0, to: 5) }
    impressive { Faker::Number.between(from: 0, to: 15) }
    midair { Faker::Number.between(from: 0, to: 10) }
    perfect { Faker::Number.between(from: 0, to: 5) }
    perforated { Faker::Number.between(from: 0, to: 5) }
    quadgod { Faker::Number.between(from: 0, to: 5) }
    rampage { Faker::Number.between(from: 0, to: 5) }
    revenge { Faker::Number.between(from: 0, to: 5) }

    # Weapons Data
    bfg_accuracy { Faker::Number.between(from: 0, to: 100) }
    bfg_time { Faker::Number.between(from: 0, to: 5000) }

    cg_accuracy { Faker::Number.between(from: 0, to: 100) }
    cg_time { Faker::Number.between(from: 0, to: 5000) }

    g_accuracy { Faker::Number.between(from: 0, to: 100) }
    g_time { Faker::Number.between(from: 0, to: 5000) }

    gl_accuracy { Faker::Number.between(from: 0, to: 100) }
    gl_time { Faker::Number.between(from: 0, to: 5000) }

    hmg_accuracy { Faker::Number.between(from: 0, to: 100) }
    hmg_time { Faker::Number.between(from: 0, to: 5000) }

    lg_accuracy { Faker::Number.between(from: 0, to: 100) }
    lg_time { Faker::Number.between(from: 0, to: 5000) }

    mg_accuracy { Faker::Number.between(from: 0, to: 100) }
    mg_time { Faker::Number.between(from: 0, to: 5000) }

    ng_accuracy { Faker::Number.between(from: 0, to: 100) }
    ng_time { Faker::Number.between(from: 0, to: 5000) }

    ow_accuracy { Faker::Number.between(from: 0, to: 100) }
    ow_time { Faker::Number.between(from: 0, to: 5000) }

    pg_accuracy { Faker::Number.between(from: 0, to: 100) }
    pg_time { Faker::Number.between(from: 0, to: 5000) }

    pm_accuracy { Faker::Number.between(from: 0, to: 100) }
    pm_time { Faker::Number.between(from: 0, to: 5000) }

    rg_accuracy { Faker::Number.between(from: 0, to: 100) }
    rg_time { Faker::Number.between(from: 0, to: 5000) }

    rl_accuracy { Faker::Number.between(from: 0, to: 100) }
    rl_time { Faker::Number.between(from: 0, to: 5000) }

    sg_accuracy { Faker::Number.between(from: 0, to: 100) }
    sg_time { Faker::Number.between(from: 0, to: 5000) }

    game_average_accuracy { Faker::Number.between(from: 0, to: 100) }

    created_at { Faker::Time.between(from: 1.year.ago, to: Time.zone.now, period: :all) }
    updated_at { created_at }
  end
end
