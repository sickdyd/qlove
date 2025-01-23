class MedalsStat < BaseMaterializedView
  self.primary_key = :player_id

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

  def self.leaderboard(params)
    medals = params[:medals]
    # The headers differs based on the medals requested, so we dynamically define the headers
    self.const_set(:HEADERS, %w[player_name total_medals] + medals.map(&:to_s))

    columns = %i[player_name steam_id] + medals.map(&:to_sym)
    total_medals_expr = medals.map { |medal| "COALESCE(#{medal}, 0)" }.join(' + ')

    super(**params) do |query|
      # To handle the year filtering
      query = yield(query) if block_given?

      query
        .select(columns)
        .select("#{total_medals_expr} AS total_medals")
    end
  end
end
