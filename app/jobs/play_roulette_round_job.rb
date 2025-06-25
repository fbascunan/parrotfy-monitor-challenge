class PlayRouletteRoundJob < ApplicationJob
  queue_as :default

  def perform
    Rounds::PlayRouletteRound.new.call
  end
end
