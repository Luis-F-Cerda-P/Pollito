class BettingPoolMembership < ApplicationRecord
  belongs_to :betting_pool
  belongs_to :user

  validates :role, presence: true, inclusion: { in: %w[admin member] }
  validates :joined_at, presence: true
  validates :user_id, uniqueness: { scope: :betting_pool_id, message: "already a member of this betting pool" }

  scope :admin, -> { where(role: "admin") }
  scope :member, -> { where(role: "member") }

  def admin?
    role == "admin"
  end

  def member?
    role == "member"
  end

  def promote_to_admin
    update!(role: "admin")
  end

  def demote_to_member
    update!(role: "member")
  end
end
