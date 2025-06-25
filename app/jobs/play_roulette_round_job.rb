class PlayRouletteRoundJob < ApplicationJob
  queue_as :default

  def perform
    PlayRouletteRoundService.new.call
  end
end
