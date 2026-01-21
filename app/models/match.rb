class Match < ApplicationRecord
  belongs_to :event

  has_many :match_participants, dependent: :destroy
  has_many :participants, through: :match_participants
  has_many :results, through: :match_participants

  has_many :predictions, dependent: :destroy

  has_one_attached :image

  # TODO: match_status should be programatically set, where:
  # an 'unset' has one or less participants, like a quarter final fixture where there's a peding match to determine the second team;
  # a 'set' match has all its participants determined (2 or more), but match_date is still in the future;
  # an 'ongoing' match has a 'match_date' in the past and either is missing Result records, or those result records are not 'final'
  # (at the time of time of this comment, the Result model is planned but not yet implemented, so the 'final' flag on them could eventually not exist);
  # a 'finished' match is done, closed for modification
  enum :match_status, { unset: 0, set: 1, ongoing: 2, finished: 3 }

  validates :match_date, presence: true
  # TODO: round should be extracted into the Phase model, which belongs to Event,
  # to which Match belongs in turn, and that declares that Match 'has_one :event, trough: :phase'.
  # Phases could be 'group-stage', 'quarter-finals', 'finals', etc
  validates :round, presence: true, numericality: { greater_than: 0 }

  scope :by_event, ->(event) { where(event_id: event) }
end
