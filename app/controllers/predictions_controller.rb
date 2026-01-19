class PredictionsController < ApplicationController
  before_action :set_prediction, only: [ :show, :edit, :update, :destroy ]
  before_action :require_authentication

  def index
    if Current.user
      @predictions = Prediction.where(user: Current.user).includes(:match, :betting_pool).order(created_at: :desc)
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
      @matches = @selected_pool.matches.includes(:team1, :team2)
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
        @matches = @selected_pool.event.matches.includes(:team1, :team2)
      else
        @matches = Match.none
      end
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize_prediction!
  end

  def update
    authorize_prediction!

    if @prediction.update(prediction_params)
      redirect_to @prediction.betting_pool, notice: "Prediction was successfully updated."
    else
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
    params.require(:prediction).permit(:betting_pool_id, :match_id, :predicted_score1, :predicted_score2)
  end
end
