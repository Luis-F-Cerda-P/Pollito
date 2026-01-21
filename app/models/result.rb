class Result < ApplicationRecord
  belongs_to :match_participant

  validates :score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :match_participant_id, uniqueness: true  # One result per participant
end
