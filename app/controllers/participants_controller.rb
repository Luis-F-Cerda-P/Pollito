class ParticipantsController < ApplicationController
  before_action :set_participant, only: [ :show, :edit, :update, :destroy ]
  before_action :require_admin!

  def index
    @participants = Participant.all.order(:name)
  end

  def show
  end

  def new
    @participant = Participant.new
  end

  def create
    @participant = Participant.new(participant_params)

    if @participant.save
      redirect_to @participant, notice: "Participant was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @participant.update(participant_params)
      redirect_to @participant, notice: "Participant was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @participant.destroy
    redirect_to participants_url, notice: "Participant was successfully deleted."
  end

  private

  def set_participant
    @participant = Participant.find(params[:id])
  end

  def participant_params
    params.require(:participant).permit(:name)
  end
end
