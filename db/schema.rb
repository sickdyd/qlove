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

ActiveRecord::Schema[8.0].define(version: 2025_01_26_113527) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "players", force: :cascade do |t|
    t.string "steam_id", null: false
    t.string "name", default: "UnnamedPlayer", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["steam_id"], name: "index_players_on_steam_id", unique: true
  end

  create_table "stats", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.string "match_guid", null: false
    t.integer "deaths", default: 0
    t.integer "kills", default: 0
    t.integer "lose", default: 0
    t.integer "play_time", default: 0
    t.integer "quit", default: 0
    t.integer "rank", default: 0
    t.integer "score", default: 0
    t.integer "win", default: 0
    t.integer "damage_dealt", default: 0
    t.integer "damage_taken", default: 0
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
    t.integer "bfg_accuracy", default: 0
    t.integer "bfg_time", default: 0
    t.integer "cg_accuracy", default: 0
    t.integer "cg_time", default: 0
    t.integer "g_accuracy", default: 0
    t.integer "g_time", default: 0
    t.integer "gl_accuracy", default: 0
    t.integer "gl_time", default: 0
    t.integer "hmg_accuracy", default: 0
    t.integer "hmg_time", default: 0
    t.integer "lg_accuracy", default: 0
    t.integer "lg_time", default: 0
    t.integer "mg_accuracy", default: 0
    t.integer "mg_time", default: 0
    t.integer "ng_accuracy", default: 0
    t.integer "ng_time", default: 0
    t.integer "ow_accuracy", default: 0
    t.integer "ow_time", default: 0
    t.integer "pg_accuracy", default: 0
    t.integer "pg_time", default: 0
    t.integer "pm_accuracy", default: 0
    t.integer "pm_time", default: 0
    t.integer "rg_accuracy", default: 0
    t.integer "rg_time", default: 0
    t.integer "rl_accuracy", default: 0
    t.integer "rl_time", default: 0
    t.integer "sg_accuracy", default: 0
    t.integer "sg_time", default: 0
    t.integer "game_average_accuracy", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_stats_on_created_at"
    t.index ["player_id"], name: "index_stats_on_player_id"
  end

  add_foreign_key "stats", "players"
end
