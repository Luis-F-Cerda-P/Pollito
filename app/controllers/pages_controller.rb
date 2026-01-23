class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[ home ]

  def home
    if authenticated?
      # User's active pools
      @user_pools = Current.user.betting_pools.includes(
        :event,
        :users,
        predictions: :match
      ).order(created_at: :desc)

      # Upcoming matches that need predictions
      @pending_predictions = find_pending_predictions
    else
      # For anonymous users
      @active_events = Event.active.includes(:matches, :betting_pools)
    end
  end

  private

  def find_pending_predictions
    user_pool_ids = Current.user.betting_pool_ids
    user_match_ids = Current.user.predictions.pluck(:match_id)

    # Matches in user's pools that they haven't predicted yet
    Match.joins(event: :betting_pools)
         .where("betting_pools.id IN (?)", user_pool_ids)
         .where.not(id: user_match_ids)
         .where("matches.match_date > ?", Time.current)
         .includes(:event, match_participants: :participant)
         .order(:match_date)
         .limit(5)
         .distinct
  end
end
