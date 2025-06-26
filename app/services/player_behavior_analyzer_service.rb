class PlayerBehaviorAnalyzerService
  attr_reader :player, :weather_service

  def initialize(player, weather_service = SantiagoWeatherService.new)
    @player = player
    @weather_service = weather_service
  end

  def analyze_betting_behavior
    {
      risk_tolerance: calculate_risk_tolerance,
      betting_strategy: determine_betting_strategy,
      color_preference: analyze_color_preference,
      bet_amount_modifier: calculate_bet_amount_modifier,
      should_skip_round: should_skip_round?
    }
  end

  def get_ai_betting_decision
    behavior = analyze_betting_behavior

    return { skip: true, reason: behavior[:should_skip_round] } if behavior[:should_skip_round]

    {
      skip: false,
      color: choose_color_with_ai(behavior),
      amount_modifier: behavior[:bet_amount_modifier],
      confidence: calculate_confidence(behavior)
    }
  end

  private

  def calculate_risk_tolerance
    # Analyze recent performance and balance trends
    recent_bets = player.bets.includes(:round).order(created_at: :desc).limit(10)
    win_rate = recent_bets.count > 0 ? recent_bets.select(&:won?).count.to_f / recent_bets.count : 0.5

    balance_ratio = player.balance / 10000.0 # Compare to starting balance

    # Risk tolerance based on performance and current situation
    if win_rate > 0.7 && balance_ratio > 1.2
      :conservative # Doing well, play it safe
    elsif win_rate < 0.3 && balance_ratio < 0.5
      :aggressive # Desperate, take risks
    elsif balance_ratio < 0.2
      :desperate # Very low balance, all-in mentality
    else
      :balanced # Normal behavior
    end
  end

  def determine_betting_strategy
    risk_tolerance = calculate_risk_tolerance

    case risk_tolerance
    when :conservative
      :percentage_based
    when :aggressive
      :momentum_based
    when :desperate
      :all_in
    else
      :balanced
    end
  end

  def analyze_color_preference
    recent_bets = player.bets.includes(:round).order(created_at: :desc).limit(20)
    color_counts = recent_bets.group_by(&:color).transform_values(&:count)

    # Find most and least used colors
    most_used = color_counts.max_by { |_, count| count }&.first
    least_used = color_counts.min_by { |_, count| count }&.first

    # AI might try to break patterns or follow winning streaks
    if recent_bets.any?
      last_bet = recent_bets.first
      if last_bet.won?
        # Won last time, might stick with same color or try something different
        [ last_bet.color, least_used ].compact.sample
      else
        # Lost last time, might change strategy - use weighted random instead of just rejecting
        available_colors = ["red", "black", "green"].reject { |c| c == last_bet.color }
        available_colors.sample
      end
    else
      # New player, use weighted random choice
      weights = { "red" => 49, "black" => 49, "green" => 2 }
      total = weights.values.sum
      random = rand(total)

      cumulative_weight = 0
      weights.each do |color, weight|
        cumulative_weight += weight
        return color if random < cumulative_weight
      end

      # Fallback
      ["red", "black", "green"].sample
    end
  end

  def calculate_bet_amount_modifier
    risk_tolerance = calculate_risk_tolerance
    recent_performance = analyze_recent_performance

    base_modifier = case risk_tolerance
    when :conservative then 0.7
    when :aggressive then 1.3
    when :desperate then 2.0
    else 1.0
    end

    # Adjust based on recent performance
    performance_modifier = case recent_performance
    when :hot then 1.2
    when :cold then 0.8
    else 1.0
    end

    # Weather influence
    weather_modifier = weather_service.hot_weather_forecast? ? 0.6 : 1.0

    (base_modifier * performance_modifier * weather_modifier).round(2)
  end

  def should_skip_round?
    # AI might decide to skip a round based on various factors
    recent_losses = player.bets.includes(:round).order(created_at: :desc).limit(5).select { |b| !b.won? }.count

    # Skip if lost 4+ times in a row (superstitious behavior)
    return true if recent_losses >= 4

    # Skip if balance is very low and weather is bad
    if player.balance < 500 && weather_service.hot_weather_forecast?
      return true
    end

    # Random chance to skip (realistic human behavior)
    rand < 0.05 # 5% chance to skip
  end

  def analyze_recent_performance
    recent_bets = player.bets.includes(:round).order(created_at: :desc).limit(10)
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

  def choose_color_with_ai(behavior)
    preference = behavior[:color_preference]
    risk_tolerance = behavior[:risk_tolerance]

    # AI might override preference based on risk tolerance
    case risk_tolerance
    when :conservative
      # Prefer red/black over green (safer bets)
      [ "red", "black" ].include?(preference) ? preference : [ "red", "black" ].sample
    when :aggressive
      # More likely to try green for big wins
      rand < 0.15 ? "green" : preference
    when :desperate
      # High risk, might go for green
      rand < 0.25 ? "green" : preference
    else
      preference
    end
  end

  def calculate_confidence(behavior)
    # Calculate AI confidence in this decision (0.0 to 1.0)
    base_confidence = 0.5

    # Adjust based on risk tolerance
    risk_confidence = case behavior[:risk_tolerance]
    when :conservative then 0.8
    when :aggressive then 0.6
    when :desperate then 0.4
    else 0.7
    end

    # Adjust based on recent performance
    performance = analyze_recent_performance
    performance_confidence = case performance
    when :hot then 0.8
    when :cold then 0.4
    else 0.6
    end

    ((base_confidence + risk_confidence + performance_confidence) / 3.0).round(2)
  end
end
