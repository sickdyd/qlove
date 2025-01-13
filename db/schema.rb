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

ActiveRecord::Schema[7.2].define(version: 2025_01_13_095437) do
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

  create_view "daily_damage_stats", materialized: true, sql_definition: <<-SQL
      SELECT players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.damage_dealt) AS total_damage_dealt,
      sum(stats.damage_taken) AS total_damage_taken
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    WHERE (stats.created_at >= date_trunc('day'::text, now()))
    GROUP BY players.id, players.steam_id;
  SQL
  add_index "daily_damage_stats", ["player_id"], name: "index_daily_damage_stats_on_player_id", unique: true
  add_index "daily_damage_stats", ["steam_id"], name: "index_daily_damage_stats_on_steam_id", unique: true

  create_view "weekly_damage_stats", materialized: true, sql_definition: <<-SQL
      SELECT players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.damage_dealt) AS total_damage_dealt,
      sum(stats.damage_taken) AS total_damage_taken
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    WHERE (stats.created_at >= date_trunc('week'::text, now()))
    GROUP BY players.id, players.steam_id;
  SQL
  add_index "weekly_damage_stats", ["player_id"], name: "index_weekly_damage_stats_on_player_id", unique: true
  add_index "weekly_damage_stats", ["steam_id"], name: "index_weekly_damage_stats_on_steam_id", unique: true

  create_view "monthly_damage_stats", materialized: true, sql_definition: <<-SQL
      SELECT players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.damage_dealt) AS total_damage_dealt,
      sum(stats.damage_taken) AS total_damage_taken
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    WHERE (stats.created_at >= date_trunc('month'::text, now()))
    GROUP BY players.id, players.steam_id;
  SQL
  add_index "monthly_damage_stats", ["player_id"], name: "index_monthly_damage_stats_on_player_id", unique: true
  add_index "monthly_damage_stats", ["steam_id"], name: "index_monthly_damage_stats_on_steam_id", unique: true

  create_view "yearly_damage_stats", materialized: true, sql_definition: <<-SQL
      SELECT players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.damage_dealt) AS total_damage_dealt,
      sum(stats.damage_taken) AS total_damage_taken,
      (EXTRACT(year FROM stats.created_at))::integer AS year
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    GROUP BY players.id, players.steam_id, (EXTRACT(year FROM stats.created_at));
  SQL
  add_index "yearly_damage_stats", ["player_id", "year"], name: "index_yearly_damage_stats_on_player_id_and_year", unique: true
  add_index "yearly_damage_stats", ["steam_id", "year"], name: "index_yearly_damage_stats_on_steam_id_and_year", unique: true

  create_view "all_time_damage_stats", materialized: true, sql_definition: <<-SQL
      SELECT players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.damage_dealt) AS total_damage_dealt,
      sum(stats.damage_taken) AS total_damage_taken
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    GROUP BY players.id, players.steam_id;
  SQL
  add_index "all_time_damage_stats", ["player_id"], name: "index_all_time_damage_stats_on_player_id", unique: true
  add_index "all_time_damage_stats", ["steam_id"], name: "index_all_time_damage_stats_on_steam_id", unique: true

  create_view "daily_kills_deaths_stats", materialized: true, sql_definition: <<-SQL
      SELECT players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.kills) AS total_kills,
      sum(stats.deaths) AS total_deaths,
          CASE
              WHEN (sum(stats.deaths) = 0) THEN NULL::numeric
              ELSE round(((sum(stats.kills))::numeric / (sum(stats.deaths))::numeric), 2)
          END AS kills_deaths_ratio
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    WHERE (stats.created_at >= date_trunc('day'::text, now()))
    GROUP BY players.id, players.steam_id;
  SQL
  add_index "daily_kills_deaths_stats", ["player_id"], name: "index_daily_kills_deaths_stats_on_player_id", unique: true
  add_index "daily_kills_deaths_stats", ["steam_id"], name: "index_daily_kills_deaths_stats_on_steam_id", unique: true

  create_view "weekly_kills_deaths_stats", materialized: true, sql_definition: <<-SQL
      SELECT players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.kills) AS total_kills,
      sum(stats.deaths) AS total_deaths,
          CASE
              WHEN (sum(stats.deaths) = 0) THEN NULL::numeric
              ELSE round(((sum(stats.kills))::numeric / (sum(stats.deaths))::numeric), 2)
          END AS kills_deaths_ratio
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    WHERE (stats.created_at >= date_trunc('week'::text, now()))
    GROUP BY players.id, players.steam_id;
  SQL
  add_index "weekly_kills_deaths_stats", ["player_id"], name: "index_weekly_kills_deaths_stats_on_player_id", unique: true
  add_index "weekly_kills_deaths_stats", ["steam_id"], name: "index_weekly_kills_deaths_stats_on_steam_id", unique: true

  create_view "monthly_kills_deaths_stats", materialized: true, sql_definition: <<-SQL
      SELECT players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.kills) AS total_kills,
      sum(stats.deaths) AS total_deaths,
          CASE
              WHEN (sum(stats.deaths) = 0) THEN NULL::numeric
              ELSE round(((sum(stats.kills))::numeric / (sum(stats.deaths))::numeric), 2)
          END AS kills_deaths_ratio
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    WHERE (stats.created_at >= date_trunc('month'::text, now()))
    GROUP BY players.id, players.steam_id;
  SQL
  add_index "monthly_kills_deaths_stats", ["player_id"], name: "index_monthly_kills_deaths_stats_on_player_id", unique: true
  add_index "monthly_kills_deaths_stats", ["steam_id"], name: "index_monthly_kills_deaths_stats_on_steam_id", unique: true

  create_view "yearly_kills_deaths_stats", materialized: true, sql_definition: <<-SQL
      SELECT players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.kills) AS total_kills,
      sum(stats.deaths) AS total_deaths,
      (EXTRACT(year FROM stats.created_at))::integer AS year,
          CASE
              WHEN (sum(stats.deaths) = 0) THEN NULL::numeric
              ELSE round(((sum(stats.kills))::numeric / (sum(stats.deaths))::numeric), 2)
          END AS kills_deaths_ratio
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    WHERE (stats.created_at >= date_trunc('day'::text, now()))
    GROUP BY players.id, players.steam_id, (EXTRACT(year FROM stats.created_at));
  SQL
  add_index "yearly_kills_deaths_stats", ["player_id"], name: "index_yearly_kills_deaths_stats_on_player_id", unique: true
  add_index "yearly_kills_deaths_stats", ["steam_id"], name: "index_yearly_kills_deaths_stats_on_steam_id", unique: true

  create_view "all_time_kills_deaths_stats", materialized: true, sql_definition: <<-SQL
      SELECT players.id AS player_id,
      players.name AS player_name,
      players.steam_id,
      sum(stats.kills) AS total_kills,
      sum(stats.deaths) AS total_deaths,
          CASE
              WHEN (sum(stats.deaths) = 0) THEN NULL::numeric
              ELSE round(((sum(stats.kills))::numeric / (sum(stats.deaths))::numeric), 2)
          END AS kills_deaths_ratio
     FROM (stats
       JOIN players ON ((players.id = stats.player_id)))
    GROUP BY players.id, players.steam_id;
  SQL
  add_index "all_time_kills_deaths_stats", ["player_id"], name: "index_all_time_kills_deaths_stats_on_player_id", unique: true
  add_index "all_time_kills_deaths_stats", ["steam_id"], name: "index_all_time_kills_deaths_stats_on_steam_id", unique: true

end
