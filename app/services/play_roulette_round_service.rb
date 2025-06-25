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

    Player.active.find_each do |player|
      PlaceBetService.new(player, round, weather_service).call
    end

    process_results(round)
    broadcast_round_complete(round)

    round
  end

  private

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
