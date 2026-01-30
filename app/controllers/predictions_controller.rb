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

    # Load predicted_results for existing predictions to ensure correct ID handling
    # For new predictions, nested attributes from form will create them
    @prediction.predicted_results.load unless @prediction.new_record?

    # Build the appropriate params based on match type
    effective_params = @match.multi_nominee? ? build_multi_nominee_params : prediction_params

    # For existing predictions, inject predicted_result IDs if missing from form
    # This handles the case where Turbo Stream updates don't refresh the hidden ID fields
    unless @prediction.new_record?
      effective_params = inject_predicted_result_ids(effective_params)
    end

    if @prediction.update(effective_params)
      @prediction.reload  # Ensure fresh state with correct IDs for Turbo Stream re-render

      # Calculate progress for Turbo Stream update
      open_matches = @betting_pool.event.matches.bets_open
      user_predictions = @betting_pool.predictions.where(user: Current.user, match: open_matches)
      @prediction_progress = { completed: user_predictions.count, total: open_matches.count }

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

  def build_multi_nominee_params
    winner_mp_id = params[:predicted_winner_mp_id].to_i
    base_params = params.require(:prediction).permit(predicted_results_attributes: [ :id, :match_participant_id ])

    # Set score=1 for winner, score=0 for others
    if base_params[:predicted_results_attributes].present?
      base_params[:predicted_results_attributes].each do |_, attrs|
        attrs[:score] = (attrs[:match_participant_id].to_i == winner_mp_id) ? 1 : 0
      end
    end

    base_params
  end

  def inject_predicted_result_ids(effective_params)
    return effective_params unless @prediction.predicted_results.any?

    params_hash = effective_params.to_h.deep_dup
    existing_by_mp_id = @prediction.predicted_results.index_by(&:match_participant_id)

    if params_hash["predicted_results_attributes"].present?
      params_hash["predicted_results_attributes"].each do |_key, attrs|
        next if attrs["id"].present?

        mp_id = attrs["match_participant_id"].to_i
        existing_pr = existing_by_mp_id[mp_id]
        attrs["id"] = existing_pr.id if existing_pr
      end
    end

    params_hash
  end
end
