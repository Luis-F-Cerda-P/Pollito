class BettingPoolMembership < ApplicationRecord
  belongs_to :betting_pool
  belongs_to :user

  validates :user_id, uniqueness: { scope: :betting_pool_id, message: "already a member of this betting pool" }

  def admin?
    betting_pool.creator == user
  end

  def recalculate_total_score!
    # Get all matches in this betting pool's event
    match_ids = betting_pool.event.matches.pluck(:id)

    # Sum scores from all this user's predictions for those matches
    total = user.predictions
                .where(match_id: match_ids)
                .sum(:total_points)

    update!(score: total)
  end
end
