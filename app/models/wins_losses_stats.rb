class WinsLossesStats < BaseMaterializedView
  self.abstract_class = true

  TOTAL_WINS_COLUMN = 'total_wins'.freeze
  TOTAL_LOSSES_COLUMN = 'total_losses'.freeze
  HEADERS = %w[player_name total_wins total_losses].freeze
end
