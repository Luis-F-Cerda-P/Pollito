class PredictedResult < ApplicationRecord
  belongs_to :prediction
  belongs_to :match_participant

  validates :score, numericality: { in: 0..9 }, allow_nil: true
  validates :match_participant_id, uniqueness: { scope: :prediction_id }

  validate :match_participant_must_belong_to_prediction_match

  private

  def match_participant_must_belong_to_prediction_match
    return unless match_participant && prediction

    if match_participant.match_id != prediction.match_id
      errors.add(:match_participant, "must belong to the prediction's match")
    end
  end
end
