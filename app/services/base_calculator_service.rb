class BaseCalculatorService
  include TimeFilterable

  HAVE_ALL_TIME_MATERIALIZED_VIEWS = [DamageStat, KillsDeathsStat, WinsLossesStat, MedalsStat].freeze

  attr_reader :time_filter, :timezone, :limit, :formatted_table, :sort_by, :medals, :weapons, :steam_id

  def initialize(time_filter:, timezone:, limit:, formatted_table:, sort_by:, medals: nil, weapons: nil, steam_id: nil)
    @time_filter = time_filter
    @timezone = timezone
    @limit = limit
    @formatted_table = formatted_table
    @sort_by = sort_by
    @medals = medals
    @weapons = weapons
    @steam_id = steam_id
  end

  def leaderboard
    formatted_table ? model.to_table(data: results, headers: headers, time_filter: time_filter, sort_by: sort_by) : results
  end

  private

  def results
    (time_filter == 'all_time' && have_all_time_materialized_view?) ? all_time_results : time_filter_results
  end

  def have_all_time_materialized_view?
    HAVE_ALL_TIME_MATERIALIZED_VIEWS.include?(model)
  end

  def all_time_results
    model.all_time(
      timezone: timezone,
      limit: limit,
      sort_by: sort_by,
      medals: medals
    )
  end

  def time_filter_results
    raise NotImplementedError
  end

  def start_time
    TimeFilterable.start_time_for(time_filter: time_filter, timezone: timezone)
  end

  def model
    raise NotImplementedError
  end

  # Some heders are dynamic based on the medals or weapons
  def headers
    if model == MedalsStat
      model.headers(medals)
    elsif model == AccuracyStat
      model.headers(weapons)
    else
      model::HEADERS
    end
  end
end
