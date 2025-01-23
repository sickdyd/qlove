class MedalCalculatorService
  include TimeFilterable

  ALL_MEDALS = %w[
    accuracy
    assists
    captures
    combokill
    defends
    excellent
    firstfrag
    headshot
    humiliation
    impressive
    midair
    perfect
    perforated
    quadgod
    rampage
    revenge
  ].freeze


  def self.medals(time_filter:, timezone:, limit:, medals: ALL_MEDALS, formatted_table:)
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    return [] unless start_time.present?

    Rails.logger.info("Medals: #{medals}")

    begin
      query = Medal.joins(stat: :player).where('stats.created_at >= ?', start_time)

      selected_medals = medals.map { |medal| "SUM(medals.#{medal}) as #{medal}" }
      total_column = medals.map { |medal| "SUM(medals.#{medal})" }.join(" + ")

      results = query
        .select(
          'players.name as player_name',
          'players.steam_id as steam_id',
          "#{total_column} AS total_medals",
          *selected_medals
        )
        .group('players.id', 'players.name', 'players.steam_id')
        .order('total_medals DESC')
        .limit(limit)

      final_results = results.map do |result|
        player_data = {
          steam_id: result.steam_id,
          player_name: result.player_name,
          total_medals: result.total_medals.to_i
        }

        medal_data = medals.each_with_object({}) do |medal, hash|
          hash[medal] = result[medal].to_i
        end

        player_data.merge(medals: medal_data)
      end

      return formatted_table ? formatted_table(data: final_results, time_filter: time_filter) : final_results
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Error in MedalCalculatorService: #{e.message}")
      []
    end
  end

  private

  def self.formatted_table(data:, time_filter:)
    title = "Medals for the #{time_filter}"
    headers = %w[player_name total_kills total_deaths kill_death_ratio]
    TabletizeService.new(title: title, data: data, headers: headers).table
  end
end
