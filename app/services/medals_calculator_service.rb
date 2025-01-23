class MedalsCalculatorService < BaseCalculatorService
  private

  def model
    MedalsStat
  end

  def time_filter_results
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

    results.map do |result|
      player_data = {
        steam_id: result.steam_id,
        player_name: result.player_name,
        total_medals: result.total_medals.to_i
      }

      medals.each do |medal|
        player_data[medal.to_sym] = result[medal].to_i
      end

      player_data
    end
  end
end
