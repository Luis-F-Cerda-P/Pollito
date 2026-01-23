class Event < ApplicationRecord
  has_many :stages, dependent: :destroy
  has_many :matches, through: :stages
  has_many :betting_pools, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :start_date, presence: true
  validates :end_date, presence: true, comparison: { greater_than_or_equal_to: :start_date }

  scope :active, -> () { where("end_date >= ?", Date.today) }

  def active?
    Date.current.between?(start_date, end_date)
  end

  def upcoming?
    Date.current < start_date
  end

  def completed?
    Date.current > end_date
  end
end
