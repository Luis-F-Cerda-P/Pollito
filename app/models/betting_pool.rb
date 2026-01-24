class BettingPool < ApplicationRecord
  belongs_to :event
  belongs_to :creator, class_name: "User"

  has_many :betting_pool_memberships, dependent: :destroy
  has_many :users, through: :betting_pool_memberships
  has_many :predictions, dependent: :destroy

  validates :creator, presence: true
  validates :name, presence: true
  validates :name, uniqueness: { scope: :event_id, message: "must be unique within this event" }

  after_create :add_creator_as_admin

  def add_user(user, role: :member)
    return false if user_in_pool?(user)

    membership = betting_pool_memberships.create!(
      user: user,
      role: role
    )
    membership
  end

  def remove_user(user)
    membership = betting_pool_memberships.find_by(user: user)
    membership&.destroy
  end

  def user_in_pool?(user)
    users.include?(user)
  end

  def user_role(user)
    membership = betting_pool_memberships.find_by(user: user)
    membership&.role
  end

  def admin?(user)
    user_role(user) == "admin"
  end

  def member_count
    users.count
  end

  def predictions_for_match(match)
    predictions.where(match: match)
  end

  private

  def add_creator_as_admin
    betting_pool_memberships.find_or_create_by!(user: creator) do |m|
      m.role = :admin
    end
  end
end
