class MedalsCalculatorService < BaseCalculatorService
  private

  def model
    MedalsStat
  end

  def time_filter_results
    query = Medal.joins(stat: :player).where('stats.created_at >= ?', start_time)

    safe_medals = medals.map { |medal| ActiveRecord::Base.connection.quote_column_name(medal) }

    selected_medals = safe_medals.map { |medal| "SUM(medals.#{medal}) AS #{medal}" }
    total_column = safe_medals.map { |medal| "SUM(medals.#{medal})" }.join(' + ')

    sanitized_sql = ActiveRecord::Base.sanitize_sql_array([
      "players.name AS player_name, players.steam_id AS steam_id, #{total_column} AS total_medals, #{selected_medals.join(', ')}"
    ])

    results = query
      .select(Arel.sql(sanitized_sql))
      .group('players.id', 'players.name', 'players.steam_id')
      .order(Arel.sql('total_medals DESC'))
      .limit(limit)

    results.map do |result|
      player_data = {
        steam_id: result.steam_id,
        player_name: result.player_name,
        total_medals: result.total_medals.to_i
      }

      safe_medals.each do |medal|
        player_data[medal.delete('"').to_sym] = result[medal.delete('"')].to_i
      end

      player_data
    end
  end
end
