class PoolInvitationsController < ApplicationController
  before_action :set_pool_by_invite_code
  before_action :require_authentication
  before_action :check_invite_validity

  def show
    if @betting_pool.user_in_pool?(Current.user)
      redirect_to @betting_pool, notice: "You're already a member of this pool."
      return
    end
  end

  def accept
    if @betting_pool.user_in_pool?(Current.user)
      redirect_to @betting_pool, notice: "You're already a member of this pool."
      return
    end

    @betting_pool.add_user(Current.user)
    redirect_to @betting_pool, notice: "Welcome to #{@betting_pool.name}!"
  end

  private

  def set_pool_by_invite_code
    @betting_pool = BettingPool.find_by(invite_code: params[:invite_code])

    unless @betting_pool
      redirect_to root_path, alert: "Invalid invite link."
    end
  end

  def check_invite_validity
    return unless @betting_pool

    if @betting_pool.invite_expired?
      redirect_to root_path, alert: "This invite link has expired."
    end
  end
end
