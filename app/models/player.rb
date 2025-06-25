class Player < ApplicationRecord
  has_many :bets, dependent: :destroy
  has_many :rounds, through: :bets

  validates :name, presence: true, uniqueness: true
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where("balance > 0") }

  def can_bet?
    balance > 0
  end

  def all_in?
    balance <= 1000
  end

  def update_balance!(amount)
    update!(balance: balance + amount)
  end
end
