class RoundsController < ApplicationController
  before_action :set_round, only: [ :show, :edit, :update, :destroy ]

  # GET /rounds
  def index
    @rounds = Round.recent.includes(:bets => :player).limit(50)
  end

  # GET /rounds/1
  def show
    @round = Round.includes(:bets => :player).find(params[:id])
  end

  # GET /rounds/new
  def new
    @round = Round.new
  end

  # GET /rounds/1/edit
  def edit
  end

  # POST /rounds
  def create
    @round = Round.new(round_params)

    if @round.save
      redirect_to @round, notice: "Round was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /rounds/1
  def update
    if @round.update(round_params)
      redirect_to @round, notice: "Round was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /rounds/1
  def destroy
    @round.destroy
    redirect_to rounds_url, notice: "Round was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_round
      @round = Round.includes(:bets => :player).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def round_params
      params.require(:round).permit(:result, :total_bets)
    end
end
