class ChangeAiDecisionToJson < ActiveRecord::Migration[8.0]
  def change
    change_column :bets, :ai_decision, :json, using: 'ai_decision::json'
  end
end
