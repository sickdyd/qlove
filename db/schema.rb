# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_01_12_024526) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "medals", force: :cascade do |t|
    t.bigint "stat_id", null: false
    t.integer "accuracy", default: 0
    t.integer "assists", default: 0
    t.integer "captures", default: 0
    t.integer "combokill", default: 0
    t.integer "defends", default: 0
    t.integer "excellent", default: 0
    t.integer "firstfrag", default: 0
    t.integer "headshot", default: 0
    t.integer "humiliation", default: 0
    t.integer "impressive", default: 0
    t.integer "midair", default: 0
    t.integer "perfect", default: 0
    t.integer "perforated", default: 0
    t.integer "quadgod", default: 0
    t.integer "rampage", default: 0
    t.integer "revenge", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stat_id"], name: "index_medals_on_stat_id"
  end

  create_table "pickups", force: :cascade do |t|
    t.bigint "stat_id", null: false
    t.integer "ammo", default: 0
    t.integer "armor", default: 0
    t.integer "armor_regen", default: 0
    t.integer "battlesuit", default: 0
    t.integer "doubler", default: 0
    t.integer "flight", default: 0
    t.integer "green_armor", default: 0
    t.integer "guard", default: 0
    t.integer "haste", default: 0
    t.integer "health", default: 0
    t.integer "invis", default: 0
    t.integer "invulnerability", default: 0
    t.integer "kamikaze", default: 0
    t.integer "medkit", default: 0
    t.integer "mega_health", default: 0
    t.integer "other_holdable", default: 0
    t.integer "other_powerup", default: 0
    t.integer "portal", default: 0
    t.integer "quad", default: 0
    t.integer "red_armor", default: 0
    t.integer "regen", default: 0
    t.integer "scout", default: 0
    t.integer "teleporter", default: 0
    t.integer "yellow_armor", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stat_id"], name: "index_pickups_on_stat_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "steam_id", null: false
    t.string "name", default: "UnnamedPlayer", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["steam_id"], name: "index_players_on_steam_id", unique: true
  end

  create_table "stats", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.boolean "aborted", default: false
    t.integer "blue_flag_pickups", default: 0
    t.integer "damage_dealt", default: 0
    t.integer "damage_taken", default: 0
    t.integer "deaths", default: 0
    t.integer "holy_shits", default: 0
    t.integer "kills", default: 0
    t.integer "lose", default: 0
    t.string "match_guid", null: false
    t.integer "max_streak", default: 0
    t.integer "neutral_flag_pickups", default: 0
    t.integer "play_time", default: 0
    t.boolean "quit", default: false
    t.integer "rank", default: 0
    t.integer "red_flag_pickups", default: 0
    t.integer "score", default: 0
    t.integer "team", default: 0
    t.integer "team_join_time", default: 0
    t.integer "team_rank", default: 0
    t.integer "tied_rank", default: 0
    t.integer "tied_team_rank", default: 0
    t.boolean "warmup", default: false
    t.integer "win", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_stats_on_player_id"
  end

  create_table "weapons", force: :cascade do |t|
    t.bigint "stat_id", null: false
    t.string "name", null: false
    t.integer "deaths", default: 0
    t.integer "damage_given", default: 0
    t.integer "damage_received", default: 0
    t.integer "hits", default: 0
    t.integer "kills", default: 0
    t.integer "pickups", default: 0
    t.integer "shots", default: 0
    t.integer "time", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stat_id"], name: "index_weapons_on_stat_id"
  end

  add_foreign_key "medals", "stats"
  add_foreign_key "pickups", "stats"
  add_foreign_key "stats", "players"
  add_foreign_key "weapons", "stats"

  create_view "damage_calculator_days", materialized: true, sql_definition: <<-SQL
      SELECT row_number() OVER (ORDER BY players.id) AS id,
      players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.damage_dealt) AS total_damage_dealt,
      sum(stats.damage_taken) AS total_damage_taken
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    WHERE (stats.created_at >= date_trunc('day'::text, now()))
    GROUP BY players.id, players.name, players.steam_id;
  SQL
  add_index "damage_calculator_days", ["player_id"], name: "index_damage_calculator_days_on_player_id", unique: true
  add_index "damage_calculator_days", ["total_damage_dealt"], name: "index_damage_calculator_days_on_total_damage_dealt"
  add_index "damage_calculator_days", ["total_damage_taken"], name: "index_damage_calculator_days_on_total_damage_taken"

  create_view "damage_calculator_weeks", materialized: true, sql_definition: <<-SQL
      SELECT row_number() OVER (ORDER BY players.id) AS id,
      players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.damage_dealt) AS total_damage_dealt,
      sum(stats.damage_taken) AS total_damage_taken
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    WHERE (stats.created_at >= date_trunc('week'::text, now()))
    GROUP BY players.id, players.name, players.steam_id;
  SQL
  add_index "damage_calculator_weeks", ["player_id"], name: "index_damage_calculator_weeks_on_player_id", unique: true
  add_index "damage_calculator_weeks", ["total_damage_dealt"], name: "index_damage_calculator_weeks_on_total_damage_dealt"
  add_index "damage_calculator_weeks", ["total_damage_taken"], name: "index_damage_calculator_weeks_on_total_damage_taken"

  create_view "damage_calculator_months", materialized: true, sql_definition: <<-SQL
      SELECT row_number() OVER (ORDER BY players.id) AS id,
      players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.damage_dealt) AS total_damage_dealt,
      sum(stats.damage_taken) AS total_damage_taken
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    WHERE (stats.created_at >= date_trunc('month'::text, now()))
    GROUP BY players.id, players.name, players.steam_id;
  SQL
  add_index "damage_calculator_months", ["player_id"], name: "index_damage_calculator_months_on_player_id", unique: true
  add_index "damage_calculator_months", ["total_damage_dealt"], name: "index_damage_calculator_months_on_total_damage_dealt"
  add_index "damage_calculator_months", ["total_damage_taken"], name: "index_damage_calculator_months_on_total_damage_taken"

  create_view "damage_calculator_all_times", materialized: true, sql_definition: <<-SQL
      SELECT row_number() OVER (ORDER BY players.id) AS id,
      players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.damage_dealt) AS total_damage_dealt,
      sum(stats.damage_taken) AS total_damage_taken
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    GROUP BY players.id, players.name, players.steam_id;
  SQL
  add_index "damage_calculator_all_times", ["player_id"], name: "index_damage_calculator_all_times_on_player_id", unique: true
  add_index "damage_calculator_all_times", ["total_damage_dealt"], name: "index_damage_calculator_all_times_on_total_damage_dealt"
  add_index "damage_calculator_all_times", ["total_damage_taken"], name: "index_damage_calculator_all_times_on_total_damage_taken"

  create_view "damage_calculator_years", materialized: true, sql_definition: <<-SQL
      SELECT row_number() OVER (ORDER BY players.id) AS id,
      players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.damage_dealt) AS total_damage_dealt,
      sum(stats.damage_taken) AS total_damage_taken
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    WHERE (stats.created_at >= date_trunc('year'::text, now()))
    GROUP BY players.id, players.name, players.steam_id;
  SQL
  add_index "damage_calculator_years", ["player_id"], name: "index_damage_calculator_years_on_player_id", unique: true
  add_index "damage_calculator_years", ["total_damage_dealt"], name: "index_damage_calculator_years_on_total_damage_dealt"
  add_index "damage_calculator_years", ["total_damage_taken"], name: "index_damage_calculator_years_on_total_damage_taken"

end
