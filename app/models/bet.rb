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
  
  # AI decision getters
  def ai_emotional_state
    ai_decision&.dig('emotional_state') || 'unknown'
  end
  
  def ai_confidence
    ai_decision&.dig('confidence') || 0.0
  end
  
  def ai_reasoning
    ai_decision&.dig('reasoning') || 'No AI analysis available'
  end
  
  def ai_risk_tolerance
    ai_decision&.dig('risk_tolerance') || 'unknown'
  end
end
