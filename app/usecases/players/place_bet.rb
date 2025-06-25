class Players::PlaceBet
  attr_reader :player, :round, :weather_service
  
  def initialize(player, round, weather_service = Weather::SantiagoService.new)
    @player = player
    @round = round
    @weather_service = weather_service
  end
  
  def call
    return false unless player.can_bet?
    
    bet_amount = calculate_bet_amount
    bet_color = choose_bet_color
    
    bet = player.bets.create!(
      round: round,
      amount: bet_amount,
      color: bet_color
    )
    
    player.update_balance!(-bet_amount)
    round.update!(total_bets: round.total_bets + bet_amount)
    
    bet
  end
  
  private
  
  def calculate_bet_amount
    if player.all_in?
      player.balance
    else
      percentage = betting_percentage
      (player.balance * percentage / 100.0).round(2)
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
  
  def choose_bet_color
    rand = Random.rand(100)
    case rand
    when 0..1 then 'green'
    when 2..50 then 'red'
    else 'black'
    end
  end
end 