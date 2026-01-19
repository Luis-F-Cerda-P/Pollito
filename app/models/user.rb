class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :betting_pools, foreign_key: :creator_id, dependent: :destroy
  has_many :betting_pool_memberships, dependent: :destroy
  has_many :joined_pools, through: :betting_pool_memberships, source: :betting_pool
  has_many :predictions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def created_pools
    betting_pools
  end

  def member_of_pools
    joined_pools
  end

  def predictions_for_pool(pool)
    predictions.where(betting_pool: pool)
  end

  def prediction_for_match(match, pool)
    predictions.find_by(match: match, betting_pool: pool)
  end

  def betting_pools
    BettingPool.where("creator_id = ? OR id IN (SELECT betting_pool_id FROM betting_pool_memberships WHERE user_id = ?)", id, id)
  end
end
