class AddAiDecisionToBets < ActiveRecord::Migration[8.0]
  def change
    add_column :bets, :ai_decision, :text
  end
end
