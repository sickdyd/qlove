class AccuracyCalculatorService < BaseCalculatorService
  AVERAGE_ACCURACY_COLUMN = "avg".freeze

  def leaderboard
    weapon_accuracies_sums = Stat
      .joins(:player)
      .where("stats.created_at >= ?", start_time)
      .select("
        players.id,
        players.name,
        players.steam_id,
        #{weapon_accuracies_sql}
      ")
      .group("
        players.id,
        players.steam_id,
        players.name
      ")

    accuracy_per_weapon = Stat
      .with(weapon_accuracies_sums: weapon_accuracies_sums)
      .from("weapon_accuracies_sums")
      .select("
        weapon_accuracies_sums.id,
        weapon_accuracies_sums.name,
        weapon_accuracies_sums.steam_id,
        #{accuracy_per_weapon_sql}
      ")

    query = Stat
      .with(accuracy_per_weapon: accuracy_per_weapon)
      .from("accuracy_per_weapon")
      .select("
        accuracy_per_weapon.id,
        accuracy_per_weapon.name,
        accuracy_per_weapon.steam_id,
        ROUND(
          (#{weapons_average_nominator_sql}) /
          NULLIF(
            #{weapons_average_denominator_sql}, 0
          ), 0
        ) AS #{AVERAGE_ACCURACY_COLUMN},
        #{select_weapons_sql}
      ")
      .order("#{AVERAGE_ACCURACY_COLUMN} DESC NULLS LAST")

    query = query.where("steam_id = ?", steam_id) if steam_id.present?

    data = query.limit(limit)

    handle_query_results(data)
  end

  private

  def weapon_accuracies_sql
    @weapons.map do |weapon|
      "SUM(#{weapon}_accuracy) as #{weapon}_total_accuracy, COUNT(*) FILTER (WHERE #{weapon}_accuracy > 0) AS #{weapon}_total_entries"
    end.join(", ")
  end

  def accuracy_per_weapon_sql
    @weapons.map do |weapon|
      "ROUND(#{weapon}_total_accuracy / NULLIF(#{weapon}_total_entries, 0), 0) as #{weapon}"
    end.join(", ")
  end

  def weapons_average_nominator_sql
    @weapons.map { |weapon| "COALESCE(#{weapon}, 0)" }.join(" + ")
  end

  def weapons_average_denominator_sql
    @weapons.map do |weapon|
      "CASE WHEN #{weapon} IS NOT NULL AND #{weapon} > 0 THEN 1 ELSE 0 END"
    end.join(" + ")
  end

  def select_weapons_sql
    @weapons.map { |weapon| "accuracy_per_weapon.#{weapon}" }.join(", ")
  end

  def headers
    [ "name", "avg" ] + @weapons
  end
end
