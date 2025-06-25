# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample players
players = [
  { name: "Alice Johnson", balance: 10000.0 },
  { name: "Bob Smith", balance: 10000.0 },
  { name: "Carol Davis", balance: 10000.0 },
  { name: "David Wilson", balance: 10000.0 },
  { name: "Eva Brown", balance: 10000.0 }
]

players.each do |player_data|
  Player.find_or_create_by!(name: player_data[:name]) do |player|
    player.balance = player_data[:balance]
  end
end

puts "Created #{Player.count} players"

# Create a sample round with bets
if Round.count.zero?
  round = Round.create!(
    result: Round.generate_result,
    total_bets: 0
  )
  
  Player.all.each do |player|
    bet_amount = rand(800..1500) # 8-15% of 10000
    bet_color = ['red', 'black', 'green'].sample
    
    bet = player.bets.create!(
      round: round,
      amount: bet_amount,
      color: bet_color
    )
    
    player.update_balance!(-bet_amount)
  end
  
  # Update round total
  round.update!(total_bets: round.bets.sum(:amount))
  
  # Process results
  round.bets.each do |bet|
    winnings = bet.winnings
    bet.player.update_balance!(winnings) if winnings > 0
  end
  
  puts "Created sample round with #{round.bets.count} bets"
end
