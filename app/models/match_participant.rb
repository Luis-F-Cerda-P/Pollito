class MatchParticipant < ApplicationRecord
  belongs_to :match, inverse_of: :match_participants
  belongs_to :participant

  has_one :result, dependent: :destroy
  has_many :predicted_results, dependent: :destroy

  accepts_nested_attributes_for :result
end
