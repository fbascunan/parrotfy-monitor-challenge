class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Add indexes for commonly queried fields
    add_index :bets, :created_at
    add_index :bets, :color
    add_index :bets, :amount
    add_index :rounds, :created_at
    add_index :rounds, :result
    add_index :players, :balance
    
    # Composite indexes for common query patterns
    add_index :bets, [:player_id, :created_at]
    add_index :bets, [:round_id, :created_at]
    add_index :bets, [:color, :created_at]
  end
end 