class Match < ApplicationRecord
  belongs_to :event

  has_many :match_participants
  has_many :participants, through: :match_participants
  has_many :predictions, dependent: :destroy

  has_one_attached :image

  validates :match_date, presence: true
  validates :round, presence: true, numericality: { greater_than: 0 }

  scope :by_event, ->(event) { where(event_id: event) }
end
