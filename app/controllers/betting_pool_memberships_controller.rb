class BettingPoolMembershipsController < ApplicationController
  before_action :set_betting_pool, only: %i[ index new create ]
  before_action :set_betting_pool_membership, only: %i[ show edit update destroy ]

  # GET /betting_pool_memberships or /betting_pool_memberships.json
  def index
    @betting_pool_memberships = @betting_pool.betting_pool_memberships
  end

  # GET /betting_pool_memberships/1 or /betting_pool_memberships/1.json
  def show
  end

  # GET /betting_pool_memberships/new
  def new
    @betting_pool_membership = @betting_pool.betting_pool_membership.build
  end

  # GET /betting_pool_memberships/1/edit
  def edit
  end

  # POST /betting_pool_memberships or /betting_pool_memberships.json
  def create
    @betting_pool_membership =  @betting_pool.betting_pool_membership.build(betting_pool_membership_params)

    respond_to do |format|
      if @betting_pool_membership.save
        format.html { redirect_to @betting_pool_membership, notice: "Betting pool membership was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /betting_pool_memberships/1 or /betting_pool_memberships/1.json
  def update
    respond_to do |format|
      if @betting_pool_membership.update(betting_pool_membership_params)
        format.html { redirect_to @betting_pool_membership, notice: "Betting pool membership was successfully updated.", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /betting_pool_memberships/1 or /betting_pool_memberships/1.json
  def destroy
    @betting_pool_membership.destroy!

    respond_to do |format|
      format.html { redirect_to betting_pool_betting_pool_memberships_path, notice: "Betting pool membership was successfully destroyed.", status: :see_other }
    end
  end

  private

    def set_betting_pool
      @betting_pool = BettingPool.find(params[:betting_pool_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_betting_pool_membership
      @betting_pool_membership = BettingPoolMembership.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def betting_pool_membership_params
      params.fetch(:betting_pool_membership, {})
    end
end
