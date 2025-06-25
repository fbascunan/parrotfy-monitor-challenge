class Bet < ApplicationRecord
  belongs_to :player
  belongs_to :round
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :color, presence: true, inclusion: { in: %w[red black green] }
  validates :player_id, uniqueness: { scope: :round_id, message: "can only bet once per round" }
  
  scope :winners, -> { joins(:round).where('bets.color = rounds.result') }
  scope :losers, -> { joins(:round).where.not('bets.color = rounds.result') }
  
  def won?
    color == round.result
  end
  
  def winnings
    won? ? amount * round.winning_multiplier : 0
  end
end
