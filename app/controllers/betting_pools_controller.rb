class BettingPoolsController < ApplicationController
  before_action :set_betting_pool, only: [ :show, :edit, :update, :destroy ]
  before_action :require_authentication

  def index
    @betting_pools = BettingPool.includes(:event, :creator).all
  end

  def show
    @memberships = @betting_pool.betting_pool_memberships.includes(:user)
    @predictions = @betting_pool.predictions.includes(:user, :match)
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
    @betting_pool = BettingPool.find(params[:id])

    membership = @betting_pool.betting_pool_memberships.find_or_initialize_by(user: Current.user)
    membership.joined_at = Time.current if membership.new_record?
    membership.role = "member"

    if membership.save
      redirect_to @betting_pool, notice: "Successfully joined the betting pool!"
    else
      redirect_to @betting_pool, alert: "Unable to join the betting pool."
    end
  end

  def leave
    @betting_pool = BettingPool.find(params[:id])
    membership = @betting_pool.betting_pool_memberships.find_by(user: Current.user)

    if membership&.destroy
      redirect_to betting_pools_path, notice: "Successfully left the betting pool."
    else
      redirect_to @betting_pool, alert: "Unable to leave the betting pool."
    end
  end

  def matches
    @betting_pool = BettingPool.find(params[:id])
    @matches = @betting_pool.event.matches.includes(:team1, :team2).order(:match_date)

    render json: @matches.map { |match|
      {
        id: match.id,
        team1_name: match.team1&.name,
        team2_name: match.team2&.name,
        match_date: match.match_date.strftime("%b %d, %Y %H:%M")
      }
    }
  end

  private

  def set_betting_pool
    @betting_pool = BettingPool.includes(:event, :creator).find(params[:id])
  end

  def betting_pool_params
    params.require(:betting_pool).permit(:name, :event_id)
  end
end
