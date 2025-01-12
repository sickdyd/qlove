class DamageCalculatorService
  include TimeFilterable

  TOTAL_DAMAGE_DEALT_COLUMN = 'total_damage_dealt'.freeze
  TOTAL_DAMAGE_TAKEN_COLUMN = 'total_damage_taken'.freeze

  DAMAGE_CALCULATOR_MAPPING = {
    :day => DamageCalculatorDay,
    :week => DamageCalculatorWeek,
    :month => DamageCalculatorMonth,
    :year => DamageCalculatorYear,
    :all_time => DamageCalculatorAllTime
  }

  def self.damage_dealt(params)
    calculate_damage(**params.merge(sort_by: TOTAL_DAMAGE_DEALT_COLUMN))
  end

  def self.damage_taken(params)
    calculate_damage(**params.merge(sort_by: TOTAL_DAMAGE_TAKEN_COLUMN))
  end

  private

  def self.calculate_damage(time_filter:, timezone:, limit:, formatted_table:, sort_by:)
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    return [] unless start_time.present?

    begin
      data = DAMAGE_CALCULATOR_MAPPING[time_filter.to_sym]
        .order("#{sort_by} DESC")
        .limit(limit)

      return formatted_table ? formatted_table(data: data, time_filter: time_filter, sort_by: sort_by) : data
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Error in DamageCalculatorService: #{e.message}")
      []
    end
  end

  def self.formatted_table(data:, time_filter:, sort_by:)
    title = "#{sort_by.titleize} for the #{time_filter}"
    headers = %w[player_name total_damage_dealt total_damage_taken]
    TabletizeService.new(title: title, data: data, headers: headers).table
  end
end
