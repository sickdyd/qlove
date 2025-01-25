class AccuracyCalculatorService < BaseCalculatorService
  private

  def time_filter_results
    average_header = AccuracyStat::SHORTENED_HEADERS[:average_accuracy].to_sym
    query = steam_id.present? ? AccuracyStat.where(steam_id: steam_id) : AccuracyStat

    query = query.where(created_at: start_time..Time.current)
      .where(weapon_name: weapons)
      .group(:steam_id, :weapon_name, :player_name)
      .order(:steam_id)

    data = query.pluck(:steam_id, :player_name, :weapon_name, "SUM(total_shots)", "SUM(total_hits)").map do |steam_id, player_name, weapon_name, total_shots, total_hits|
      accuracy = total_shots.zero? ? AccuracyStat::UNAVAILABLE_ACCURACY : (total_hits.to_f / total_shots.to_f * 100).round

      {
        steam_id: steam_id,
        player_name: player_name,
        weapon_name: weapon_name,
        accuracy: accuracy
      }
    end

    transformed_data = data.group_by { |entry| entry[:steam_id] }.map do |steam_id, entries|
      player_name = entries.first[:player_name]

      weapon_data = entries.each_with_object({}) do |entry, hash|
        hash[AccuracyStat::SHORTENED_WEAPON_NAMES[entry[:weapon_name].to_s].to_sym] = entry[:accuracy]
      end

      valid_accuracies = weapon_data.values.reject { |v| v == AccuracyStat::UNAVAILABLE_ACCURACY }
      avg_accuracy = valid_accuracies.any? ? (valid_accuracies.sum / valid_accuracies.size).round : AccuracyStat::UNAVAILABLE_ACCURACY

      { steam_id: steam_id, player_name: player_name }
        .merge(weapon_data)
        .merge(average_header => avg_accuracy)
    end

    transformed_data.sort_by { |entry| entry[average_header] == "-" ? -Float::INFINITY : entry[average_header] }.reverse.take(limit.to_i)
  end

  def model
    AccuracyStat
  end
end
