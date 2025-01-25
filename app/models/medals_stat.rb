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

  TOTAL_MEDALS_COLUMN = "total_medals".freeze

  HEADERS = %w[player_name total_medals].concat(ALL_MEDALS).freeze

  def self.all_time(params)
    medals = params[:medals]

    columns = %i[player_id player_name steam_id] + medals.map(&:to_sym)
    total_medals_expr = medals.map { |medal| "COALESCE(#{medal}, 0)" }.join(" + ")

    super(**params) do |query|
      query = query
        .select(columns)
        .select("#{total_medals_expr} AS total_medals")

      from(query, :medals_stats)
    end
  end

  def self.headers(medals)
    %w[player_name total_medals] + medals.map(&:to_s)
  end
end
