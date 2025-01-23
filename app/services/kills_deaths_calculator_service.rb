class KillsDeathsCalculatorService < BaseCalculatorService
  private

  def model
    KillsDeathsStat
  end

  def time_filter_results
    query = Stat.where('stats.created_at >= ?', start_time).joins(:player)

    results = query
      .select(
        'players.name as player_name',
        'players.steam_id as steam_id',
        'SUM(stats.kills) as total_kills',
        'SUM(stats.deaths) as total_deaths'
      )
      .group('players.id', 'players.name', 'players.steam_id')
      .order("#{sort_by} DESC")
      .limit(limit)

      results.map do |result|
        {
          steam_id: result.steam_id,
          player_name: result.player_name,
          total_kills: result.total_kills.to_i,
          total_deaths: result.total_deaths.to_i,
          kill_death_ratio: kill_death_ratio(result)
        }
      end
  end

  def kill_death_ratio(result)
    result.total_deaths.to_i.zero? ? result.total_kills.to_i : (result.total_kills.to_f / result.total_deaths.to_f).round(2)
  end
end
