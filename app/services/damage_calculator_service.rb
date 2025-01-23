class DamageCalculatorService < BaseCalculatorService
  private

  def model
    DamageStat
  end

  def time_filter_results
    query = Stat.where('stats.created_at >= ?', start_time).joins(:player)

    results = query
      .select(
        'players.name as player_name',
        'players.steam_id as steam_id',
        'SUM(stats.damage_dealt) as total_damage_dealt',
        'SUM(stats.damage_taken) as total_damage_taken'
      )
      .group('players.id', 'players.name', 'players.steam_id')
      .order("#{sort_by} DESC")
      .limit(limit)

    results.map do |result|
      {
        steam_id: result.steam_id,
        player_name: result.player_name,
        total_damage_dealt: result.total_damage_dealt.to_i,
        total_damage_taken: result.total_damage_taken.to_i
      }
    end
  end
end
