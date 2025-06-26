class PlayRouletteRoundService
  attr_reader :weather_service

  def initialize(weather_service = SantiagoWeatherService.new)
    @weather_service = weather_service
  end

  def call
    round = Round.create!(
      result: Round.generate_result,
      total_bets: 0
    )

    # Get all active players
    active_players = Player.active.includes(:bets => :round).all
    
    # Use batch AI analysis for all players at once
    ai_analysis = analyze_players_batch(active_players)
    
    # Process each player's bet based on AI analysis
    active_players.each do |player|
      player_analysis = ai_analysis.find { |analysis| analysis[:player] == player }
      process_player_bet(player, round, player_analysis)
    end

    process_results(round)
    broadcast_round_complete(round)

    round
  end

  private

  def analyze_players_batch(players)
    return [] if players.empty?
    
    # Use batch AI analyzer for better performance
    batch_analyzer = BatchAiAnalyzerService.new(players, weather_service)
    batch_analyzer.analyze_all_players_for_round
  end

  def process_player_bet(player, round, ai_analysis)
    return unless player.can_bet?
    return if ai_analysis&.dig(:should_skip_round)

    # Calculate bet amount based on AI analysis
    bet_amount = calculate_bet_amount(player, ai_analysis)
    bet_color = ai_analysis&.dig(:color) || choose_random_color

    # Store AI decision data
    ai_data = {
      emotional_state: ai_analysis&.dig(:emotional_state) || "neutral",
      risk_tolerance: ai_analysis&.dig(:risk_tolerance) || "balanced",
      confidence: ai_analysis&.dig(:confidence) || 0.5,
      reasoning: ai_analysis&.dig(:reasoning) || "AI analysis unavailable",
      amount_modifier: ai_analysis&.dig(:bet_amount_modifier) || 1.0
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
    Rails.logger.info "Batch AI Decision for #{player.name}: " \
                     "Color=#{bet_color}, Amount=$#{bet_amount}, " \
                     "Confidence=#{ai_data[:confidence]}, " \
                     "Emotional State=#{ai_data[:emotional_state]}, " \
                     "Reasoning=#{ai_data[:reasoning]}"
  end

  def calculate_bet_amount(player, ai_analysis)
    if player.all_in?
      player.balance
    else
      base_percentage = betting_percentage
      ai_modifier = ai_analysis&.dig(:bet_amount_modifier) || 1.0
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

  def choose_random_color
    weights = { "red" => 49, "black" => 49, "green" => 2 }
    total = weights.values.sum
    random = rand(total)

    cumulative_weight = 0
    weights.each do |color, weight|
      cumulative_weight += weight
      return color if random < cumulative_weight
    end

    # Fallback to random selection if something goes wrong
    ["red", "black", "green"].sample
  end

  def process_results(round)
    round.bets.includes(:player).each do |bet|
      winnings = bet.winnings
      bet.player.update_balance!(winnings) if winnings > 0
    end
  end

  def broadcast_round_complete(round)
    ActionCable.server.broadcast(
      "roulette_channel",
      {
        type: "round_complete",
        round_id: round.id,
        result: round.result,
        total_bets: round.total_bets,
        players_count: round.players.count
      }
    )
  end
end
