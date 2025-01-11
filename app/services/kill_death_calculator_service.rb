class KillDeathCalculatorService
  include TimeFilterable

  TOTAL_KILLS_COLUMN = 'total_kills'.freeze
  TOTAL_DEATHS_COLUMN = 'total_deaths'.freeze
  # TODO: add kdr
  KILL_DEATH_RATIO_COLUMN = 'kill_death_ratio'.freeze

  def self.kills(params)
    calculate_kills_and_deaths(**params.merge(sort_by: TOTAL_KILLS_COLUMN))
  end

  def self.deaths(params)
    calculate_kills_and_deaths(**params.merge(sort_by: TOTAL_DEATHS_COLUMN))
  end

  private

  def self.calculate_kills_and_deaths(time_filter:, timezone:, limit:, formatted_table:, sort_by:)
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    return [] unless start_time.present?

    begin
      results = Stat.where('stats.created_at >= ?', start_time)
        .joins(:player)
        .select(
          'players.name as player_name',
          'players.steam_id as steam_id',
          'SUM(stats.kills) as total_kills',
          'SUM(stats.deaths) as total_deaths'
        )
        .group('players.id', 'players.name', 'players.steam_id')
        .order("#{sort_by} DESC")
        .limit(limit)

      final_results = results.map do |result|
        {
          steam_id: result.steam_id,
          player_name: result.player_name,
          total_kills: result.total_kills.to_i,
          total_deaths: result.total_deaths.to_i,
          kill_death_ratio: result.total_deaths.to_i.zero? ? result.total_kills.to_i : (result.total_kills.to_f / result.total_deaths.to_f).round(2)
        }
      end

      return formatted_table ? formatted_table(data: final_results, time_filter: time_filter, sort_by: sort_by) : final_results
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Error in KillDeathCalculatorService: #{e.message}")
      []
    end
  end

  def self.formatted_table(data:, time_filter:, sort_by:)
    title = "#{sort_by.titleize} for the #{time_filter}"
    headers = %w[player_name total_kills total_deaths kill_death_ratio]
    TabletizeService.new(title: title, data: data, headers: headers).table
  end
end
