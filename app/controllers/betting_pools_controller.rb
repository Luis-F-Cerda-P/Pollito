class BettingPoolsController < ApplicationController
  before_action :set_betting_pool, only: [ :show, :edit, :update, :destroy, :join ]
  before_action :require_authentication
  before_action :authorize_member!, only: [ :show ]
  before_action :authorize_creator!, only: [ :edit, :update, :destroy ]
  before_action :authorize_public_pool!, only: [ :join ]

  def index
    @betting_pools = BettingPool.visible_to(Current.user)
                                .includes(:event, :creator, :betting_pool_memberships)
  end

  def show
    @memberships = @betting_pool.betting_pool_memberships.includes(:user)
    @predictions = @betting_pool.predictions.includes(
      :user,
      match: { match_participants: [ :participant, :result ] },
      predicted_results: { match_participant: :participant }
    ).order(created_at: :desc).limit(10)

    # Load matches for predictions section
    @matches_by_stage = @betting_pool.event.matches
                          .includes(:stage, match_participants: :participant)
                          .joins(:stage)
                          .order("stages.name", :match_date)
                          .group_by(&:stage)

    @matches_chronological = @betting_pool.event.matches
                               .includes(:stage, match_participants: :participant)
                               .order(:match_date)

    # User's existing predictions indexed by match_id
    if Current.user && @betting_pool.user_in_pool?(Current.user)
      @user_predictions = @betting_pool.predictions
                            .where(user: Current.user)
                            .includes(predicted_results: :match_participant)
                            .index_by(&:match_id)

      # Progress stats
      open_count = @betting_pool.event.matches.bets_open.count
      predicted_count = @user_predictions.values.count { |p| p.match.bets_open? }
      @prediction_progress = { completed: predicted_count, total: open_count }
    else
      @user_predictions = {}
      @prediction_progress = { completed: 0, total: 0 }
    end
  end

  def new
    @betting_pool = BettingPool.new
    @events = Event.all
  end

  def create
    @betting_pool = BettingPool.new(betting_pool_params)
    @betting_pool.creator = Current.user

    if @betting_pool.save
      @betting_pool.add_user(@betting_pool.creator)
      redirect_to @betting_pool, notice: "Betting pool was successfully created."
    else
      @events = Event.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @events = Event.all
  end

  def update
    if @betting_pool.update(betting_pool_params)
      redirect_to @betting_pool, notice: "Betting pool was successfully updated."
    else
      @events = Event.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @betting_pool.destroy
    redirect_to betting_pools_url, notice: "Betting pool was successfully deleted."
  end

  def join
    if @betting_pool.user_in_pool?(Current.user)
      respond_to do |format|
        format.html { redirect_to @betting_pool, notice: "You are already a member of this pool." }
        format.turbo_stream { redirect_to @betting_pool, notice: "You are already a member of this pool." }
      end
      return
    end

    @betting_pool.add_user(Current.user)
    respond_to do |format|
      format.html { redirect_to @betting_pool, notice: "You have successfully joined the pool!" }
      format.turbo_stream
    end
  end

  private

  def set_betting_pool
    @betting_pool = BettingPool.includes(:event, :creator).find(params[:id])
  end

  def authorize_member!
    unless @betting_pool.is_public || @betting_pool.user_in_pool?(Current.user)
      redirect_to betting_pools_path, alert: "You don't have access to this pool."
    end
  end

  def authorize_creator!
    unless @betting_pool.creator == Current.user
      redirect_to @betting_pool, alert: "Only the pool creator can perform this action."
    end
  end

  def authorize_public_pool!
    unless @betting_pool.is_public
      redirect_to betting_pools_path, alert: "You can only join public pools this way. Use an invite code for private pools."
    end
  end

  def betting_pool_params
    params.require(:betting_pool).permit(:name, :event_id, :is_public)
  end
end
