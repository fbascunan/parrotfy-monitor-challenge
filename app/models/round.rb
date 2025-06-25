class Round < ApplicationRecord
  has_many :bets, dependent: :destroy
  has_many :players, through: :bets
  
  validates :result, presence: true, inclusion: { in: %w[red black green] }
  validates :total_bets, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :recent, -> { order(created_at: :desc) }
  
  def self.generate_result
    rand = Random.rand(100)
    case rand
    when 0..1 then 'green'
    when 2..50 then 'red'
    else 'black'
    end
  end
  
  def winning_multiplier
    case result
    when 'green' then 15
    when 'red', 'black' then 2
    else 0
    end
  end
end
