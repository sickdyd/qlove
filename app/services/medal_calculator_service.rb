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


  def self.medals(time_filter:, timezone:, limit:, medals: ALL_MEDALS)
    start_time = TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)

    return [] unless start_time.present?

    Rails.logger.info("Medals: #{medals}")

    begin
      query = Medal.joins(stat: :player).where('stats.created_at >= ?', start_time)

      selected_medals = medals.map { |medal| "SUM(medals.#{medal}) as #{medal}" }
      total_column = medals.map { |medal| "SUM(medals.#{medal})" }.join(" + ")

      Rails.logger.info("Selected medals: #{selected_medals}")
      Rails.logger.info("Total column: #{total_column}")

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

      results.map do |result|
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
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error("Error in MedalCalculatorService: #{e.message}")
      []
    end
  end
end
