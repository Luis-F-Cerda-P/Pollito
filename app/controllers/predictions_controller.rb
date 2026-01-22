class PredictionsController < ApplicationController
  before_action :set_prediction, only: [ :show, :edit, :update, :destroy ]
  before_action :require_authentication

  def index
    if Current.user
        @predictions = Current.user.predictions
          .includes(
            :betting_pool,
            predicted_results: { match_participant: :participant },
            match: {
              event: {},  # Empty hash, or just include it at the top level
              match_participants: [ :participant, :result ]
            }
          )
          .order(created_at: :desc)
    else
      redirect_to new_session_path, alert: "Please sign in to view your predictions."
    end
  end

  def show
    authorize_prediction!
  end

  def new
    @betting_pools = Current.user.betting_pools.includes(:event)
    @matches = Match.none

    if params[:betting_pool_id].present?
      @selected_pool = BettingPool.find(params[:betting_pool_id])
    end

    @prediction = Prediction.new
  end

  def create
    @prediction = Prediction.new(prediction_params)
    @prediction.user = Current.user

    if @prediction.save
      redirect_to @prediction.betting_pool, notice: "Prediction was successfully created."
    else
      @betting_pools = Current.user.betting_pools.includes(:event)
      if @prediction.betting_pool.present?
        @selected_pool = @prediction.betting_pool
        @matches = @selected_pool.event.matches.includes(:participants)
      else
        @matches = Match.none
      end
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @prediction = Prediction.includes(
      :betting_pool,
      predicted_results: { match_participant: :participant },
      match: [ :event, { match_participants: [ :participant, :result ] } ]
    ).find(params[:id])
  end

  def update
    @prediction = Prediction.find(params[:id])

    if @prediction.update(prediction_params)
      redirect_to @prediction.betting_pool, notice: "Prediction was successfully updated."
    else
      # Reload associations for form
      @prediction.reload
      @prediction.predicted_results.includes(match_participant: :participant)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize_prediction!

    betting_pool = @prediction.betting_pool
    @prediction.destroy
    redirect_to betting_pool, notice: "Prediction was successfully deleted."
  end

  private

  def set_prediction
    @prediction = Prediction.includes(:user, :match, :betting_pool).find(params[:id])
  end

  def authorize_prediction!
    redirect_to root_path, alert: "You are not authorized to perform this action." unless @prediction.user == Current.user
  end

  def prediction_params
    params.require(:prediction).permit(:betting_pool_id, :match_id, predicted_results_attributes: [ :id, :score ])
  end
end
