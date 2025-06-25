require "openai"

class OpenaiBehaviorAnalyzerService
  attr_reader :player, :weather_service, :client

  def initialize(player, weather_service = Weather::SantiagoService.new)
    @player = player
    @weather_service = weather_service
    @client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
  end

  def analyze_betting_behavior
    player_profile = build_player_profile
    recent_history = build_recent_history
    weather_context = get_weather_context

    prompt = build_analysis_prompt(player_profile, recent_history, weather_context)

    begin
      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: [
            {
              role: "system",
              content: "You are an expert psychologist analyzing casino player behavior. Provide realistic, human-like betting decisions based on player psychology, emotions, and patterns."
            },
            {
              role: "user",
              content: prompt
            }
          ],
          temperature: 0.7,
          max_tokens: 500
        }
      )

      parse_ai_response(response.dig("choices", 0, "message", "content"))
    rescue => e
      Rails.logger.error "OpenAI API error: #{e.message}"
      fallback_behavior_analysis
    end
  end

  def get_ai_betting_decision
    behavior = analyze_betting_behavior

    return { skip: true, reason: behavior[:should_skip_round] } if behavior[:should_skip_round]

    {
      skip: false,
      color: behavior[:color],
      amount_modifier: behavior[:bet_amount_modifier],
      confidence: behavior[:confidence],
      reasoning: behavior[:reasoning],
      emotional_state: behavior[:emotional_state]
    }
  end

  private

  def build_player_profile
    {
      name: player.name,
      current_balance: player.balance,
      starting_balance: 10000.0,
      balance_ratio: player.balance / 10000.0,
      total_bets: player.bets.count,
      total_wins: player.bets.select(&:won?).count,
      win_rate: calculate_win_rate,
      average_bet: player.bets.average(:amount)&.round(2) || 0,
      biggest_win: player.bets.maximum(:amount) || 0,
      biggest_loss: player.bets.minimum(:amount) || 0,
      favorite_color: most_frequent_color,
      betting_patterns: analyze_betting_patterns
    }
  end

  def build_recent_history
    recent_bets = player.bets.includes(:round).order(created_at: :desc).limit(10)

    recent_bets.map do |bet|
      {
        round_id: bet.round.id,
        amount: bet.amount,
        color: bet.color,
        won: bet.won?,
        winnings: bet.winnings,
        balance_after: bet.round.created_at > bet.created_at ? player.balance : "unknown"
      }
    end
  end

  def get_weather_context
    {
      is_hot: weather_service.hot_weather_forecast?,
      current_weather: weather_service.current_weather&.dig("data", "values", "temperature") || "unknown"
    }
  end

  def build_analysis_prompt(player_profile, recent_history, weather_context)
    <<~PROMPT
      Analyze this casino player's behavior and provide a realistic betting decision for the next roulette round.

      PLAYER PROFILE:
      - Name: #{player_profile[:name]}
      - Current Balance: $#{player_profile[:current_balance]}
      - Balance Ratio: #{(player_profile[:balance_ratio] * 100).round(1)}% of starting amount
      - Total Bets: #{player_profile[:total_bets]}
      - Win Rate: #{player_profile[:win_rate]}%
      - Average Bet: $#{player_profile[:average_bet]}
      - Favorite Color: #{player_profile[:favorite_color]}
      - Betting Patterns: #{player_profile[:betting_patterns].join(', ')}

      RECENT HISTORY (last 10 bets):
      #{recent_history.map { |bet| "- Round #{bet[:round_id]}: $#{bet[:amount]} on #{bet[:color]}, #{bet[:won] ? 'WON' : 'LOST'}" }.join("\n")}

      WEATHER CONTEXT:
      - Hot Weather (>23°C): #{weather_context[:is_hot]}
      - Current Temperature: #{weather_context[:current_weather]}°C

      Based on this data, provide a JSON response with:
      1. emotional_state: (frustrated, confident, desperate, cautious, excited, neutral)
      2. risk_tolerance: (conservative, balanced, aggressive, desperate)
      3. should_skip_round: (true/false with reason)
      4. color: (red/black/green with reasoning)
      5. bet_amount_modifier: (0.1 to 3.0 multiplier)
      6. confidence: (0.0 to 1.0)
      7. reasoning: (brief explanation of the decision)

      Consider human psychology: loss aversion, hot hand fallacy, gambler's fallacy, emotional states, and weather impact on mood.
    PROMPT
  end

  def parse_ai_response(response_text)
    begin
      # Extract JSON from response
      json_match = response_text.match(/\{.*\}/m)
      return fallback_behavior_analysis unless json_match

      parsed = JSON.parse(json_match[0])

      {
        emotional_state: parsed["emotional_state"] || "neutral",
        risk_tolerance: parsed["risk_tolerance"] || "balanced",
        should_skip_round: parsed["should_skip_round"] || false,
        color: parsed["color"] || choose_random_color,
        bet_amount_modifier: (parsed["bet_amount_modifier"] || 1.0).to_f.clamp(0.1, 3.0),
        confidence: (parsed["confidence"] || 0.5).to_f.clamp(0.0, 1.0),
        reasoning: parsed["reasoning"] || "AI analysis unavailable"
      }
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse OpenAI response: #{e.message}"
      fallback_behavior_analysis
    end
  end

  def fallback_behavior_analysis
    {
      emotional_state: "neutral",
      risk_tolerance: determine_fallback_risk_tolerance,
      should_skip_round: should_skip_round_fallback?,
      color: choose_random_color,
      bet_amount_modifier: calculate_fallback_modifier,
      confidence: 0.5,
      reasoning: "Fallback decision due to AI service unavailability"
    }
  end

  def calculate_win_rate
    return 0 if player.bets.empty?
    (player.bets.select(&:won?).count.to_f / player.bets.count * 100).round(2)
  end

  def most_frequent_color
    color_counts = player.bets.group_by(&:color).transform_values(&:count)
    color_counts.max_by { |_, count| count }&.first || "none"
  end

  def analyze_betting_patterns
    patterns = []

    # Check for color switching patterns
    recent_colors = player.bets.order(created_at: :desc).limit(5).pluck(:color)
    if recent_colors.uniq.length == recent_colors.length
      patterns << "color_switcher"
    elsif recent_colors.uniq.length == 1
      patterns << "color_loyalist"
    end

    # Check for bet amount patterns
    recent_amounts = player.bets.order(created_at: :desc).limit(5).pluck(:amount)
    if recent_amounts.each_cons(2).all? { |a, b| a < b }
      patterns << "increasing_bets"
    elsif recent_amounts.each_cons(2).all? { |a, b| a > b }
      patterns << "decreasing_bets"
    end

    # Check for win/loss patterns
    recent_results = player.bets.order(created_at: :desc).limit(5).map(&:won?)
    if recent_results.all?
      patterns << "hot_streak"
    elsif recent_results.none?
      patterns << "cold_streak"
    end

    patterns.empty? ? [ "unpredictable" ] : patterns
  end

  def determine_fallback_risk_tolerance
    balance_ratio = player.balance / 10000.0
    win_rate = calculate_win_rate

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

  def should_skip_round_fallback?
    recent_losses = player.bets.order(created_at: :desc).limit(5).select { |b| !b.won? }.count
    recent_losses >= 4 || (player.balance < 500 && weather_service.hot_weather_forecast?)
  end

  def choose_random_color
    weights = { "red" => 49, "black" => 49, "green" => 2 }
    total = weights.values.sum
    random = rand(total)

    weights.each do |color, weight|
      return color if random < weight
      random -= weight
    end

    "red"
  end

  def calculate_fallback_modifier
    risk_tolerance = determine_fallback_risk_tolerance

    base_modifier = case risk_tolerance
    when :conservative then 0.7
    when :aggressive then 1.3
    when :desperate then 2.0
    else 1.0
    end

    # Weather adjustment
    weather_modifier = weather_service.hot_weather_forecast? ? 0.6 : 1.0

    (base_modifier * weather_modifier).round(2)
  end
end
