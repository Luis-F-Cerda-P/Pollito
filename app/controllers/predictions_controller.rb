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
      redirect_to login_path, alert: "Please sign in to view your predictions."
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

  def upsert
    @betting_pool = BettingPool.find(params[:betting_pool_id])
    @match = Match.find(params[:match_id])

    # Authorization: must be pool member
    unless @betting_pool.user_in_pool?(Current.user)
      return head :forbidden
    end

    # Can only predict on open matches
    unless @match.bets_open?
      return head :forbidden
    end

    # Find or initialize prediction
    @prediction = Prediction.find_or_initialize_by(
      user: Current.user,
      betting_pool: @betting_pool,
      match: @match
    )

    # Build predicted_results if new
    if @prediction.new_record?
      @match.match_participants.each do |mp|
        @prediction.predicted_results.build(match_participant: mp)
      end
    end

    if @prediction.update(prediction_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @betting_pool }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :upsert_error, status: :unprocessable_entity }
        format.html { redirect_to @betting_pool, alert: @prediction.errors.full_messages.join(", ") }
      end
    end
  end

  private

  def set_prediction
    @prediction = Prediction.includes(:user, :match, :betting_pool).find(params[:id])
  end

  def authorize_prediction!
    redirect_to root_path, alert: "You are not authorized to perform this action." unless @prediction.user == Current.user
  end

  def prediction_params
    params.require(:prediction).permit(:betting_pool_id, :match_id, predicted_results_attributes: [ :id, :match_participant_id, :score ])
  end
end
