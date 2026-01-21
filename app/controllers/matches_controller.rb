class MatchesController < ApplicationController
  before_action :set_match, only: [ :show, :edit, :update, :destroy ]
  before_action :require_admin!, only: [ :new, :create, :edit, :update, :destroy ]

  def index
    @matches = Match.includes(:event, :participants).order(:match_date)
  end

  def show
  end

  def new
    @match = Match.new
    @events = Event.all
    @participants = Participant.all
  end

  def create
    @match = Match.new(match_params)

    if @match.save
      redirect_to @match, notice: "Match was successfully created."
    else
      @events = Event.all
      @participants = Participant.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @events = Event.all
    @participants = Participant.all
  end

  def update
    if @match.update(match_params)
      redirect_to @match, notice: "Match was successfully updated."
    else
      @events = Event.all
      @participants = Participant.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @match.destroy
    redirect_to matches_url, notice: "Match was successfully deleted."
  end

  private

  def set_match
    @match = Match.includes(:event, :participants).find(params[:id])
  end

  def match_params
    params.require(:match).permit(:event_id, :match_date, :round)
  end
end
