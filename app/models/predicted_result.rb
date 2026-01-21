class PredictedResult < ApplicationRecord
  belongs_to :prediction
  belongs_to :match_participant
end
