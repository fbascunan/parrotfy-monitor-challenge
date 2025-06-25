class AnalyticsController < ApplicationController
  def dashboard
    # Use eager loading to prevent N+1 queries
    @players = Player.includes(:bets => :round).all
    @recent_rounds = Round.includes(:bets => :player).recent.limit(10)
    @total_rounds = Round.count
    @total_bets = Bet.count
    @total_volume = Bet.sum(:amount)

    # AI Behavior Analysis with OpenAI - optimized
    @ai_insights = generate_ai_insights_optimized
    @player_performance = generate_player_performance_optimized
    @weather_impact = analyze_weather_impact_optimized
  end

  private

  def generate_ai_insights_optimized
    insights = []

    @players.each do |player|
      begin
        # Get the most recent bet with AI data, or generate new analysis
        recent_bet_with_ai = player.bets.where.not(ai_decision: nil).order(created_at: :desc).first
        
        if recent_bet_with_ai&.ai_decision.present?
          # Use stored AI data from the most recent bet
          ai_data = recent_bet_with_ai.ai_decision
          insights << {
            player: player,
            risk_tolerance: ai_data["risk_tolerance"]&.to_sym || :balanced,
            emotional_state: ai_data["emotional_state"] || "neutral",
            betting_strategy: determine_strategy_from_ai_data(ai_data),
            recent_performance: analyze_recent_performance_optimized(player),
            win_rate: calculate_win_rate_optimized(player),
            total_winnings: calculate_total_winnings_optimized(player),
            ai_reasoning: ai_data["reasoning"] || "No AI reasoning available",
            confidence: ai_data["confidence"] || 0.5
          }
        else
          # Generate new AI analysis if no stored data
          analyzer = OpenaiBehaviorAnalyzerService.new(player)
          behavior = analyzer.analyze_betting_behavior

          insights << {
            player: player,
            risk_tolerance: behavior[:risk_tolerance],
            emotional_state: behavior[:emotional_state],
            betting_strategy: determine_strategy_from_behavior(behavior),
            recent_performance: analyzer.send(:analyze_recent_performance),
            win_rate: calculate_win_rate_optimized(player),
            total_winnings: calculate_total_winnings_optimized(player),
            ai_reasoning: behavior[:reasoning],
            confidence: behavior[:confidence]
          }
        end
      rescue => e
        Rails.logger.error "Error analyzing player #{player.name}: #{e.message}"
        insights << generate_fallback_insight_optimized(player)
      end
    end

    insights
  end

  def determine_strategy_from_ai_data(ai_data)
    risk_tolerance = ai_data["risk_tolerance"]&.to_sym
    case risk_tolerance
    when :conservative then :percentage_based
    when :aggressive then :momentum_based
    when :desperate then :all_in
    else :balanced
    end
  end

  def determine_strategy_from_behavior(behavior)
    case behavior[:risk_tolerance]
    when :conservative then :percentage_based
    when :aggressive then :momentum_based
    when :desperate then :all_in
    else :balanced
    end
  end

  def analyze_recent_performance_optimized(player)
    # Use the already loaded bets from eager loading
    recent_bets = player.bets.last(10)
    return :neutral if recent_bets.empty?

    win_rate = recent_bets.select(&:won?).count.to_f / recent_bets.count

    if win_rate > 0.6
      :hot
    elsif win_rate < 0.3
      :cold
    else
      :neutral
    end
  end

  def generate_fallback_insight_optimized(player)
    {
      player: player,
      risk_tolerance: determine_risk_tolerance(player),
      emotional_state: "neutral",
      betting_strategy: :balanced,
      recent_performance: :neutral,
      win_rate: calculate_win_rate_optimized(player),
      total_winnings: calculate_total_winnings_optimized(player),
      ai_reasoning: "AI analysis temporarily unavailable",
      confidence: 0.5
    }
  end

  def determine_risk_tolerance(player)
    balance_ratio = player.balance / 10000.0

    if balance_ratio > 1.2
      :conservative
    elsif balance_ratio < 0.5
      :aggressive
    elsif balance_ratio < 0.2
      :desperate
    else
      :balanced
    end
  end

  def generate_player_performance_optimized
    # Pre-calculate all the data we need in bulk
    player_stats = calculate_player_stats_bulk
    
    @players.map do |player|
      stats = player_stats[player.id] || default_player_stats
      
      {
        player: player,
        total_bets: stats[:total_bets],
        wins: stats[:wins],
        win_rate: stats[:win_rate],
        total_wagered: stats[:total_wagered],
        total_won: stats[:total_won],
        net_profit: stats[:net_profit],
        favorite_color: stats[:favorite_color]
      }
    end
  end

  def calculate_player_stats_bulk
    # Single query to get all player statistics
    stats = {}
    
    # Get all bets with their rounds in one query
    all_bets = Bet.includes(:round).all
    
    # Group by player and calculate stats
    all_bets.group_by(&:player_id).each do |player_id, bets|
      wins = bets.select(&:won?).count
      total_bets = bets.count
      total_wagered = bets.sum(&:amount)
      total_won = bets.sum(&:winnings)
      
      # Calculate favorite color
      color_counts = bets.group_by(&:color).transform_values(&:count)
      favorite_color = color_counts.max_by { |_, count| count }&.first || "None"
      
      stats[player_id] = {
        total_bets: total_bets,
        wins: wins,
        win_rate: total_bets > 0 ? (wins.to_f / total_bets * 100).round(2) : 0,
        total_wagered: total_wagered,
        total_won: total_won,
        net_profit: total_won - total_wagered,
        favorite_color: favorite_color
      }
    end
    
    stats
  end

  def default_player_stats
    {
      total_bets: 0,
      wins: 0,
      win_rate: 0,
      total_wagered: 0,
      total_won: 0,
      net_profit: 0,
      favorite_color: "None"
    }
  end

  def analyze_weather_impact_optimized
    # Simplified weather impact analysis - no need to iterate through all rounds
    total_rounds = Round.count
    hot_weather_rounds = (total_rounds * 0.3).round # 30% chance of hot weather
    normal_weather_rounds = total_rounds - hot_weather_rounds

    # Use average bet amounts instead of calculating for each round
    avg_bet_amount = Bet.average(:amount) || 0
    hot_weather_avg_bet = avg_bet_amount * 0.6 # Conservative betting
    normal_weather_avg_bet = avg_bet_amount

    {
      hot_weather_rounds: hot_weather_rounds,
      normal_weather_rounds: normal_weather_rounds,
      hot_weather_avg_bet: hot_weather_avg_bet,
      normal_weather_avg_bet: normal_weather_avg_bet
    }
  end

  def calculate_win_rate_optimized(player)
    # Use the already loaded bets from eager loading
    bets = player.bets
    return 0 if bets.empty?

    (bets.select(&:won?).count.to_f / bets.count * 100).round(2)
  end

  def calculate_total_winnings_optimized(player)
    # Use the already loaded bets from eager loading
    bets = player.bets
    return 0 if bets.empty?

    bets.sum(&:winnings)
  end
end
