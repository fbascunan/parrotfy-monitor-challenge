class BatchAiAnalyzerService
  attr_reader :players, :weather_service

  def initialize(players, weather_service = SantiagoWeatherService.new)
    @players = players
    @weather_service = weather_service
  end

  def analyze_all_players_for_round
    # Build comprehensive context for all players
    context = build_round_context
    prompt = build_batch_prompt(context)
    
    # Get AI analysis for all players at once
    ai_response = get_openai_analysis(prompt)
    
    # Parse the response and return structured data
    parse_batch_response(ai_response)
  rescue => e
    Rails.logger.error "Batch AI analysis failed: #{e.message}"
    generate_fallback_analysis
  end

  private

  def build_round_context
    {
      total_players: players.count,
      weather_condition: weather_service.hot_weather_forecast? ? "hot" : "normal",
      current_temperature: weather_service.current_weather&.dig("data", "values", "temperature") || "unknown",
      betting_strategy: weather_service.hot_weather_forecast? ? "conservative (3-7%)" : "normal (8-15%)",
      round_number: Round.count + 1,
      time_of_day: Time.current.hour,
      day_of_week: Time.current.strftime("%A")
    }
  end

  def build_batch_prompt(context)
    players_data = players.map { |player| build_player_data(player) }
    
    <<~PROMPT
      You are an expert casino psychologist analyzing roulette player behavior. You MUST respond with ONLY a valid JSON array.

      ROUND CONTEXT:
      - Round Number: #{context[:round_number]}
      - Weather: #{context[:weather_condition]} (#{context[:current_temperature]}°C)
      - Betting Strategy: #{context[:betting_strategy]}
      - Time: #{context[:time_of_day]}:00 on #{context[:day_of_week]}

      PLAYERS DATA:
      #{players_data.map { |data| format_player_data(data) }.join("\n\n")}

      INSTRUCTIONS:
      For each player, provide a JSON object with:
      - emotional_state: (frustrated, confident, desperate, cautious, excited, neutral)
      - risk_tolerance: (conservative, balanced, aggressive, desperate)
      - should_skip_round: (true/false)
      - color: (red/black/green) - MUST be randomly distributed, not all the same
      - bet_amount_modifier: (0.1 to 3.0)
      - confidence: (0.0 to 1.0)
      - reasoning: (brief explanation)

      IMPORTANT: 
      - Return ONLY a JSON array with #{players.length} objects
      - Each object must have all required fields
      - Colors must be diverse (red, black, green) - NOT all the same color
      - No additional text, only JSON

      Example format:
      [
        {"emotional_state": "confident", "risk_tolerance": "balanced", "should_skip_round": false, "color": "red", "bet_amount_modifier": 1.0, "confidence": 0.7, "reasoning": "..."},
        {"emotional_state": "cautious", "risk_tolerance": "conservative", "should_skip_round": false, "color": "black", "bet_amount_modifier": 0.8, "confidence": 0.6, "reasoning": "..."}
      ]
    PROMPT
  end

  def build_player_data(player)
    recent_bets = player.bets.includes(:round).order(created_at: :desc).limit(10)
    win_rate = recent_bets.count > 0 ? recent_bets.select(&:won?).count.to_f / recent_bets.count : 0.5
    
    {
      id: player.id,
      name: player.name,
      current_balance: player.balance,
      starting_balance: 10000.0,
      balance_ratio: player.balance / 10000.0,
      total_bets: player.bets.count,
      total_wins: player.bets.select(&:won?).count,
      win_rate: win_rate,
      average_bet: player.bets.average(:amount)&.round(2) || 0,
      recent_performance: analyze_recent_performance(recent_bets),
      favorite_color: most_frequent_color(player.bets),
      betting_patterns: analyze_betting_patterns(player.bets),
      recent_bets: recent_bets.first(5).map { |bet| format_recent_bet(bet) }
    }
  end

  def format_player_data(data)
    <<~PLAYER_DATA
      Player #{data[:id]}: #{data[:name]}
      - Balance: $#{data[:current_balance]} (#{(data[:balance_ratio] * 100).round(1)}% of starting)
      - Win Rate: #{(data[:win_rate] * 100).round(1)}%
      - Total Bets: #{data[:total_bets]}
      - Avg Bet: $#{data[:average_bet]}
      - Recent Performance: #{data[:recent_performance]}
      - Favorite Color: #{data[:favorite_color]}
      - Patterns: #{data[:betting_patterns].join(', ')}
      - Recent Bets: #{data[:recent_bets].join(' | ')}
    PLAYER_DATA
  end

  def format_recent_bet(bet)
    "#{bet.color.upcase} $#{bet.amount} (#{bet.won? ? 'WON' : 'LOST'})"
  end

  def analyze_recent_performance(bets)
    return "neutral" if bets.empty?
    
    win_rate = bets.select(&:won?).count.to_f / bets.count
    if win_rate > 0.6
      "hot"
    elsif win_rate < 0.3
      "cold"
    else
      "neutral"
    end
  end

  def most_frequent_color(bets)
    return "none" if bets.empty?
    
    color_counts = bets.group_by(&:color).transform_values(&:count)
    color_counts.max_by { |_, count| count }&.first || "none"
  end

  def analyze_betting_patterns(bets)
    patterns = []
    return ["new_player"] if bets.empty?

    recent_bets = bets.order(created_at: :desc).limit(5)
    
    # Color switching patterns
    colors = recent_bets.pluck(:color)
    if colors.uniq.length == colors.length
      patterns << "color_switcher"
    elsif colors.uniq.length == 1
      patterns << "color_loyalist"
    end

    # Bet amount patterns
    amounts = recent_bets.pluck(:amount)
    if amounts.each_cons(2).all? { |a, b| a < b }
      patterns << "increasing_bets"
    elsif amounts.each_cons(2).all? { |a, b| a > b }
      patterns << "decreasing_bets"
    end

    # Win/loss patterns
    results = recent_bets.map(&:won?)
    if results.all?
      patterns << "hot_streak"
    elsif results.none?
      patterns << "cold_streak"
    end

    patterns.empty? ? ["unpredictable"] : patterns
  end

  def get_openai_analysis(prompt)
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    
    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        response_format: { type: "json_object" },
        messages: [
          {
            role: "system",
            content: "You are an expert casino psychologist analyzing roulette player behavior. You MUST respond with ONLY valid JSON arrays. Never include explanatory text. Ensure color choices are diverse (red, black, green) and not all the same. Each player should have different colors when possible."
          },
          {
            role: "user",
            content: prompt
          }
        ],
        temperature: 0.8,
        max_tokens: 2000
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue => e
    Rails.logger.error "OpenAI API error: #{e.message}"
    nil
  end

  def parse_batch_response(response_text)
    return generate_fallback_analysis unless response_text

    begin
      # Extract JSON array from response
      json_match = response_text.match(/\[.*\]/m)
      return generate_fallback_analysis unless json_match

      parsed = JSON.parse(json_match[0])
      
      # Ensure we have the right number of results
      if parsed.length != players.length
        Rails.logger.warn "AI returned #{parsed.length} results for #{players.length} players"
        return generate_fallback_analysis
      end

      # Check if all colors are the same (AI bias)
      colors = parsed.map { |p| p["color"] }.compact
      if colors.length > 1 && colors.uniq.length == 1
        Rails.logger.warn "AI returned all same color (#{colors.first}), using fallback"
        return generate_fallback_analysis
      end

      # Map results to players
      players.map.with_index do |player, index|
        player_data = parsed[index] || {}
        
        {
          player: player,
          emotional_state: player_data["emotional_state"] || "neutral",
          risk_tolerance: player_data["risk_tolerance"] || "balanced",
          should_skip_round: player_data["should_skip_round"] || false,
          color: player_data["color"] || choose_random_color,
          bet_amount_modifier: (player_data["bet_amount_modifier"] || 1.0).to_f.clamp(0.1, 3.0),
          confidence: (player_data["confidence"] || 0.5).to_f.clamp(0.0, 1.0),
          reasoning: player_data["reasoning"] || "AI analysis unavailable"
        }
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse batch AI response: #{e.message}"
      generate_fallback_analysis
    end
  end

  def generate_fallback_analysis
    players.map do |player|
      {
        player: player,
        emotional_state: "neutral",
        risk_tolerance: determine_fallback_risk_tolerance(player),
        should_skip_round: should_skip_round_fallback?(player),
        color: choose_random_color,
        bet_amount_modifier: calculate_fallback_modifier(player),
        confidence: 0.5,
        reasoning: "Fallback analysis due to AI service unavailability"
      }
    end
  end

  def determine_fallback_risk_tolerance(player)
    balance_ratio = player.balance / 10000.0
    win_rate = calculate_win_rate(player)

    if balance_ratio > 1.2 && win_rate > 60
      :conservative
    elsif balance_ratio < 0.3
      :desperate
    elsif win_rate < 30
      :aggressive
    else
      :balanced
    end
  end

  def should_skip_round_fallback?(player)
    recent_losses = player.bets.order(created_at: :desc).limit(5).select { |b| !b.won? }.count
    recent_losses >= 4 || (player.balance < 500 && weather_service.hot_weather_forecast?)
  end

  def calculate_fallback_modifier(player)
    risk_tolerance = determine_fallback_risk_tolerance(player)
    
    case risk_tolerance
    when :conservative then 0.7
    when :aggressive then 1.3
    when :desperate then 2.0
    else 1.0
    end
  end

  def calculate_win_rate(player)
    return 0 if player.bets.empty?
    (player.bets.select(&:won?).count.to_f / player.bets.count * 100).round(2)
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
end 