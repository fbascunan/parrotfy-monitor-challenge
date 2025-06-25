namespace :bets do
  desc "Update existing bets with AI decision data"
  task update_with_ai: :environment do
    puts "Updating bets without AI decision data..."
    
    bets_without_ai = Bet.where(ai_decision: nil)
    total_bets = bets_without_ai.count
    
    puts "Found #{total_bets} bets without AI data"
    
    bets_without_ai.find_each.with_index do |bet, index|
      # Create sample AI decision data
      ai_data = {
        emotional_state: ["confident", "cautious", "excited", "neutral", "frustrated"].sample,
        risk_tolerance: ["conservative", "balanced", "aggressive", "desperate"].sample,
        confidence: rand(0.3..0.9).round(2),
        reasoning: "Retroactive AI analysis for #{bet.player.name}: Based on historical data, this bet of $#{bet.amount} on #{bet.color} was likely made with #{rand(0.4..0.8).round(2)} confidence.",
        amount_modifier: rand(0.8..1.2).round(2)
      }
      
      bet.update!(ai_decision: ai_data)
      
      if (index + 1) % 10 == 0 || index + 1 == total_bets
        puts "Updated #{index + 1}/#{total_bets} bets"
      end
    end
    
    puts "✅ Successfully updated #{total_bets} bets with AI decision data"
  end
end 