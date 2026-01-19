class Admin::DashboardController < Admin::AdminController
  def index
    @users_count = User.count
    @events_count = Event.count
    @matches_count = Match.count
    @betting_pools_count = BettingPool.count
    @predictions_count = Prediction.count
  end
end
