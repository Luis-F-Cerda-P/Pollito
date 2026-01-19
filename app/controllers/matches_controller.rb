class MatchesController < ApplicationController
  before_action :set_match, only: [ :show, :edit, :update, :destroy ]

  def index
    @matches = Match.includes(:event, :team1, :team2).order(:match_date)
  end

  def show
  end

  def new
    @match = Match.new
    @events = Event.all
    @teams = Team.all
  end

  def create
    @match = Match.new(match_params)

    if @match.save
      redirect_to @match, notice: "Match was successfully created."
    else
      @events = Event.all
      @teams = Team.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @events = Event.all
    @teams = Team.all
  end

  def update
    if @match.update(match_params)
      redirect_to @match, notice: "Match was successfully updated."
    else
      @events = Event.all
      @teams = Team.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @match.destroy
    redirect_to matches_url, notice: "Match was successfully deleted."
  end

  private

  def set_match
    @match = Match.includes(:event, :team1, :team2).find(params[:id])
  end

  def match_params
    params.require(:match).permit(:event_id, :team1_id, :team2_id, :score1, :score2, :match_date, :round)
  end
end
