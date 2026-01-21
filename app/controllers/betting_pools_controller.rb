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

  private

  def set_betting_pool
    @betting_pool = BettingPool.includes(:event, :creator).find(params[:id])
  end

  def betting_pool_params
    params.require(:betting_pool).permit(:name, :event_id)
  end
end
