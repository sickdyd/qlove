class DamageCalculatorService
  include TimeFilterable

  TOTAL_DAMAGE_DEALT_COLUMN = 'total_damage_dealt'.freeze
  TOTAL_DAMAGE_TAKEN_COLUMN = 'total_damage_taken'.freeze

  def initialize(time_filter:, timezone:, limit:, formatted_table:, sort_by:)
    @time_filter = time_filter
    @timezone = timezone
    @limit = limit
    @formatted_table = formatted_table
    @sort_by = sort_by
  end

  def leaderboard
    @formatted_table ?
      DamageStat.to_table(data: results, time_filter: time_filter, sort_by: sort_by) :
      results
  end

  private

  def results
    # All time results uses the materialized view for better performance
    if @time_filter == 'all_time'
      all_time_results
    else
      time_filter_results
    end
  end

  def all_time_results
    DamageStat.all_time(
      timezone: @timezone,
      limit: @limit,
      sort_by: @sort_by,
      formatted_table: @formatted_table
    )
  end

  def time_filter_results
    query = Stat.where('stats.created_at >= ?', start_time)

    results = query.joins(:player)
      .select(
        'players.name as player_name',
        'players.steam_id as steam_id',
        'SUM(stats.damage_dealt) as total_damage_dealt',
        'SUM(stats.damage_taken) as total_damage_taken'
      )
      .group('players.id', 'players.name', 'players.steam_id')
      .order("#{@sort_by} DESC")
      .limit(@limit)

    results.map do |result|
      {
        steam_id: result.steam_id,
        player_name: result.player_name,
        total_damage_dealt: result.total_damage_dealt.to_i,
        total_damage_taken: result.total_damage_taken.to_i
      }
    end
  end

  def start_time
    TimeFilterable.start_time_for(time_filter: @time_filter, timezone: @timezone)
  end
end
