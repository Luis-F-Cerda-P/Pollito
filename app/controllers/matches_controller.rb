class MatchesController < ApplicationController
  before_action :set_match, only: [ :show, :edit, :update, :destroy ]
  before_action :require_admin!, only: [ :new, :create, :edit, :update, :destroy ]

  def index
    @matches = Match.includes(:event, match_participants: :participant).order(:match_date)
  end

  def show
    @match = Match.includes(
      :event,
      match_participants: [ :participant, :result ],
      predictions: [
        :user,
        predicted_results: { match_participant: :participant }
      ]
    ).find(params[:id])
  end

  def new
    @match = Match.new
    # Build 2 match participants by default for common case
    2.times { @match.match_participants.build }
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
    @participants = Participant.all
  end

  def update
    if @match.update(match_params)
      redirect_to @match, notice: "Match was successfully updated."
    else
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
    @match = Match.includes(
      :event,
      match_participants: [ :participant, :result ]
    ).find(params[:id])
  end

  def match_params
    params.require(:match).permit(
      :match_date, :round,
      match_participants_attributes: [
        :id, :participant_id, :_destroy,
        result_attributes: [ :id, :score ]
      ]
    )
  end
end
