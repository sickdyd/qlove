class AccuracyCalculatorService < BaseCalculatorService
  AVERAGE_ACCURACY_COLUMN = "avg".freeze

  def leaderboard
    super do |query|
      query = query.where("players.steam_id = ?", steam_id) if steam_id.present?

      query
        .select("
          players.id,
          players.steam_id,
          players.name,
          ROUND(SUM(stats.game_average_accuracy) / COUNT(CASE WHEN stats.game_average_accuracy IS NOT NULL THEN 1 END), 0)::INTEGER AS avg,
          #{weapons_accuracy_sql}
        ")
    end
  end

  private

  def short_weapon_name(weapon)
    WeaponValidatable::SHORTENED_WEAPON_NAMES[weapon]
  end

  def weapons_accuracy_sql
    weapons.map do |weapon|
      short_name = short_weapon_name(weapon)
      "COALESCE(ROUND(SUM(stats.#{short_name}_accuracy) / NULLIF(COUNT(stats.#{short_name}_accuracy), 0), 0)::INTEGER::TEXT, '-') AS #{short_name}"
    end.join(", ")
  end

  def headers
    ["name", "avg"] + weapons.map { |weapon| short_weapon_name(weapon) }
  end

  def table_title
    "Best Accuracy for the #{time_filter}"
  end
end
