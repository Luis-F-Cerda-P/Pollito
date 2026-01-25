class BettingPoolMembership < ApplicationRecord
  belongs_to :betting_pool
  belongs_to :user

  validates :user_id, uniqueness: { scope: :betting_pool_id, message: "already a member of this betting pool" }

  def admin?
    betting_pool.creator == user
  end
end
