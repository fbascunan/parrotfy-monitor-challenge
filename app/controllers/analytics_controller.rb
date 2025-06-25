class AnalyticsController < ApplicationController
  def dashboard
    @players = Player.includes(:bets, :rounds).all
    @recent_rounds = Round.recent.limit(10)
    @total_rounds = Round.count
    @total_bets = Bet.count
    @total_volume = Bet.sum(:amount)
    
    # AI Behavior Analysis (simplified for now)
    @ai_insights = generate_simple_insights
    @player_performance = generate_player_performance
    @weather_impact = analyze_weather_impact
  end
  
  private
  
  def generate_simple_insights
    players = Player.includes(:bets, :rounds).all
    insights = []
    
    players.each do |player|
      insights << {
        player: player,
        risk_tolerance: determine_risk_tolerance(player),
        betting_strategy: :balanced,
        recent_performance: :neutral,
        win_rate: calculate_win_rate(player),
        total_winnings: player.bets.winners.sum(:amount) * 2 + player.bets.joins(:round).where(color: 'green', rounds: { result: 'green' }).sum(:amount) * 13
      }
    end
    
    insights
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
  
  def generate_player_performance
    Player.includes(:bets, :rounds).all.map do |player|
      bets = player.bets.includes(:round)
      total_bets = bets.count
      wins = bets.select(&:won?).count
      
      {
        player: player,
        total_bets: total_bets,
        wins: wins,
        win_rate: total_bets > 0 ? (wins.to_f / total_bets * 100).round(2) : 0,
        total_wagered: bets.sum(:amount),
        total_won: bets.sum(&:winnings),
        net_profit: bets.sum(&:winnings) - bets.sum(:amount),
        favorite_color: bets.group_by(&:color).max_by { |_, bets| bets.count }&.first || 'None'
      }
    end
  end
  
  def analyze_weather_impact
    weather_service = Weather::SantiagoService.new
    hot_weather_rounds = []
    normal_weather_rounds = []
    
    Round.includes(:bets).all.each do |round|
      # This is a simplified analysis - in production you'd store weather data
      # For now, we'll simulate weather impact
      is_hot = rand < 0.3 # 30% chance of hot weather
      
      if is_hot
        hot_weather_rounds << round
      else
        normal_weather_rounds << round
      end
    end
    
    {
      hot_weather_rounds: hot_weather_rounds.count,
      normal_weather_rounds: normal_weather_rounds.count,
      hot_weather_avg_bet: hot_weather_rounds.any? ? hot_weather_rounds.sum { |r| r.bets.sum(:amount) } / hot_weather_rounds.count : 0,
      normal_weather_avg_bet: normal_weather_rounds.any? ? normal_weather_rounds.sum { |r| r.bets.sum(:amount) } / normal_weather_rounds.count : 0
    }
  end
  
  def calculate_win_rate(player)
    bets = player.bets
    return 0 if bets.empty?
    
    (bets.select(&:won?).count.to_f / bets.count * 100).round(2)
  end
end
