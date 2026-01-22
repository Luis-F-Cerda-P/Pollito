class MatchParticipant < ApplicationRecord
  belongs_to :match
  belongs_to :participant

  has_one :result, dependent: :destroy
  has_many :predicted_results, dependent: :destroy
end
