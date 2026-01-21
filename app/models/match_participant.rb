class MatchParticipant < ApplicationRecord
  belongs_to :match
  belongs_to :participant
end
