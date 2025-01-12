# This is used to test DB performance.

namespace :test_data do
  desc 'Populate the database with test data for performance testing'
  task populate: :environment do
    require 'faker'

    puts "Seeding database with 100 players, 3,000 stats per player, and associated weapons, pickups, and medals..."

    BATCH_SIZE = 500
    PLAYER_COUNT = 100
    STATS_PER_PLAYER = 3_000
    WEAPON_TYPES = %w[rocket railgun plasma shotgun lightning machinegun grenade]
    PICKUP_FIELDS = %i[ammo armor armor_regen battlesuit doubler flight green_armor guard haste health invis invulnerability kamikaze medkit mega_health other_holdable other_powerup portal quad red_armor regen scout teleporter yellow_armor]
    MEDAL_FIELDS = %i[accuracy assists captures combokill defends excellent firstfrag headshot humiliation impressive midair perfect perforated quadgod rampage revenge]

    players = []
    PLAYER_COUNT.times do
      players << {
        steam_id: Faker::Number.number(digits: 17).to_s,
        name: Faker::Name.name,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    Player.insert_all(players)
    puts "Inserted #{PLAYER_COUNT} players."

    def insert_batch(model, records)
      model.insert_all(records) if records.any?
    end

    stats = []
    weapons = []
    pickups = []
    medals = []

    Player.find_each(batch_size: BATCH_SIZE) do |player|
      STATS_PER_PLAYER.times do
        stat = {
          player_id: player.id,
          match_guid: SecureRandom.uuid,
          aborted: [true, false].sample,
          blue_flag_pickups: Faker::Number.between(from: 0, to: 10),
          damage_dealt: Faker::Number.between(from: 1_000, to: 10_000),
          damage_taken: Faker::Number.between(from: 500, to: 5_000),
          deaths: Faker::Number.between(from: 5, to: 25),
          holy_shits: Faker::Number.between(from: 0, to: 10),
          kills: Faker::Number.between(from: 10, to: 50),
          lose: [true, false].sample ? 1 : 0,
          max_streak: Faker::Number.between(from: 1, to: 10),
          neutral_flag_pickups: Faker::Number.between(from: 0, to: 10),
          play_time: Faker::Number.between(from: 300, to: 3600),
          quit: [true, false].sample,
          rank: Faker::Number.between(from: 1, to: 10),
          red_flag_pickups: Faker::Number.between(from: 0, to: 10),
          score: Faker::Number.between(from: 100, to: 500),
          team: Faker::Number.between(from: 0, to: 1),
          team_join_time: Faker::Number.between(from: 0, to: 300),
          team_rank: Faker::Number.between(from: 1, to: 10),
          tied_rank: Faker::Number.between(from: 0, to: 3),
          tied_team_rank: Faker::Number.between(from: 0, to: 3),
          warmup: [true, false].sample,
          win: [true, false].sample ? 1 : 0,
          created_at: Time.current,
          updated_at: Time.current
        }
        stats << stat

        WEAPON_TYPES.each do |weapon_name|
          weapons << {
            stat_id: stats.size,
            name: weapon_name,
            deaths: Faker::Number.between(from: 0, to: 20),
            damage_given: Faker::Number.between(from: 100, to: 1_000),
            damage_received: Faker::Number.between(from: 50, to: 500),
            hits: Faker::Number.between(from: 10, to: 100),
            kills: Faker::Number.between(from: 1, to: 10),
            pickups: Faker::Number.between(from: 1, to: 5),
            shots: Faker::Number.between(from: 20, to: 200),
            time: Faker::Number.between(from: 10, to: 300),
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        pickups << PICKUP_FIELDS.index_with { Faker::Number.between(from: 0, to: 20) }
          .merge({ stat_id: stats.size, created_at: Time.current, updated_at: Time.current })

        medals << MEDAL_FIELDS.index_with { Faker::Number.between(from: 0, to: 10) }
          .merge({ stat_id: stats.size, created_at: Time.current, updated_at: Time.current })
      end

      if stats.size >= BATCH_SIZE
        insert_batch(Stat, stats)
        insert_batch(Weapon, weapons)
        insert_batch(Pickup, pickups)
        insert_batch(Medal, medals)
        stats.clear
        weapons.clear
        pickups.clear
        medals.clear

        puts "Inserted stats, weapons, pickups, and medals for player #{player.id}..."
      end
    end

    insert_batch(Stat, stats)
    insert_batch(Weapon, weapons)
    insert_batch(Pickup, pickups)
    insert_batch(Medal, medals)

    puts "Seeding complete!"

  end
end
