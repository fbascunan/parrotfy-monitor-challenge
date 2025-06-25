# Load the CasinoAI module for background jobs
load Rails.root.join("app/usecases/ai.rb") unless defined?(CasinoAI)

class Players::PlaceBet
  attr_reader :player, :round, :weather_service, :ai_analyzer
  
  def initialize(player, round, weather_service = Weather::SantiagoService.new)
    @player = player
    @round = round
    @weather_service = weather_service
    @ai_analyzer = CasinoAI::OpenAIBehaviorAnalyzer.new(player, weather_service)
  end
  
  def call
    return false unless player.can_bet?
    
    # Get AI decision with OpenAI analysis
    ai_decision = ai_analyzer.get_ai_betting_decision
    
    # AI might decide to skip this round
    if ai_decision[:skip]
      Rails.logger.info "Player #{player.name} skipped round #{round.id} due to: #{ai_decision[:reason]}"
      return false
    end
    
    bet_amount = calculate_bet_amount(ai_decision[:amount_modifier])
    bet_color = ai_decision[:color]
    
    # Store AI decision data
    ai_data = {
      emotional_state: ai_decision[:emotional_state],
      risk_tolerance: ai_decision[:risk_tolerance],
      confidence: ai_decision[:confidence],
      reasoning: ai_decision[:reasoning],
      amount_modifier: ai_decision[:amount_modifier]
    }
    
    bet = player.bets.create!(
      round: round,
      amount: bet_amount,
      color: bet_color,
      ai_decision: ai_data
    )
    
    player.update_balance!(-bet_amount)
    round.update!(total_bets: round.total_bets + bet_amount)
    
    # Log detailed AI decision for debugging and analytics
    Rails.logger.info "OpenAI Decision for #{player.name}: " \
                     "Color=#{bet_color}, Amount=$#{bet_amount}, " \
                     "Confidence=#{ai_decision[:confidence]}, " \
                     "Emotional State=#{ai_decision[:emotional_state]}, " \
                     "Reasoning=#{ai_decision[:reasoning]}"
    
    bet
  end
  
  private
  
  def calculate_bet_amount(ai_modifier = 1.0)
    if player.all_in?
      player.balance
    else
      base_percentage = betting_percentage
      adjusted_percentage = (base_percentage * ai_modifier).clamp(1, 100)
      (player.balance * adjusted_percentage / 100.0).round(2)
    end
  end
  
  def betting_percentage
    if weather_service.hot_weather_forecast?
      # Conservative betting: 3-7%
      rand(3..7)
    else
      # Normal betting: 8-15%
      rand(8..15)
    end
  end
end 