class MedalsStat < BaseMaterializedView
  self.abstract_class = true

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

  TOTAL_MEDALS_COLUMN = 'total_medals'.freeze
  HEADERS = %w[player_name total_medals].concat(ALL_MEDALS).freeze

  def self.leaderboard(time_filter:, timezone:, limit:, sort_by:, formatted_table:, year: nil, medals: ALL_MEDALS)
    # The headers differs based on the medals requested, so we dynamically define the headers
    self.const_set(:HEADERS, %w[player_name total_medals] + medals.map(&:to_s))

    columns = %i[player_name steam_id] + medals.map(&:to_sym)
    total_medals_expr = medals.map { |medal| "COALESCE(#{medal}, 0)" }.join(' + ')

    super do |query|
      # To handle the year filtering
      query = yield(query) if block_given?

      query
        .select(columns)
        .select("#{total_medals_expr} AS total_medals")
    end
  end

  private

  class AllTimeMedalsStat < MedalsStat
  end

  class MonthlyMedalsStat < MedalsStat
  end

  class WeeklyMedalsStat < MedalsStat
  end

  class DailyMedalsStat < MedalsStat
  end

  class YearlyMedalsStat < MedalsStat
    def self.leaderboard(params)
      super(**params) do |query|
        query.where(year: params[:year])
      end
    end
  end

  class CustomMedalsStat < MedalsStat
  end
end
