class BaseCalculatorService
  include TimeFilterable

  attr_reader :time_filter, :timezone, :limit, :formatted_table, :sort_by, :medals

  def initialize(time_filter:, timezone:, limit:, formatted_table:, sort_by:, medals: nil)
    @time_filter = time_filter
    @timezone = timezone
    @limit = limit
    @formatted_table = formatted_table
    @sort_by = sort_by
    @medals = medals
  end

  def leaderboard
    formatted_table ? model.to_table(data: results, headers: headers, time_filter: time_filter, sort_by: sort_by) : results
  end

  private

  def results
    time_filter == 'all_time' ? all_time_results : time_filter_results
  end

  def all_time_results
    model.all_time(
      timezone: timezone,
      time_filter: time_filter,
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
    else
      model::HEADERS
    end
  end
end
