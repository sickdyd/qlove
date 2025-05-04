class PlayTimeCalculatorService < BaseCalculatorService
  include ActionView::Helpers::DateHelper
  include DOTIW::Methods

  TOTAL_PLAY_TIME_COLUMN = "total_play_time".freeze

  HEADERS = [ "name", TOTAL_PLAY_TIME_COLUMN ]

  def leaderboard
    super do |query|
      query
        .select("
          players.id as player_id,
          players.steam_id,
          players.name,
          SUM(stats.play_time) as #{TOTAL_PLAY_TIME_COLUMN}
        ")
    end
  end

  def handle_query_results(data)
    data_with_readable_play_times = data.map do |row|
      row = row.attributes if row.respond_to?(:attributes)
      row[TOTAL_PLAY_TIME_COLUMN] = distance_of_time_in_words(0, row[TOTAL_PLAY_TIME_COLUMN], compact: true)
      OpenStruct.new(row)
    end

    super(data_with_readable_play_times)
  end

  def all_time
    data = AllTimePlayTimeStat.all.limit(limit).order("#{sort_by} DESC NULLS LAST")
    handle_query_results(data)
  end
end
