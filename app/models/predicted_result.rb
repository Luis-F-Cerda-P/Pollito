class PredictedResult < ApplicationRecord
  belongs_to :prediction
  belongs_to :match_participant

  validates :match_participant_id, uniqueness: { scope: :prediction_id }

  validate :match_participant_must_belong_to_prediction_match
  validate :score_within_valid_range

  private

  def match_participant_must_belong_to_prediction_match
    return unless match_participant && prediction

    if match_participant.match_id != prediction.match_id
      errors.add(:match_participant, "must belong to the prediction's match")
    end
  end

  def score_within_valid_range
    return if score.nil?

    match = prediction&.match
    return unless match

    valid_range = match.multi_nominee? ? (0..1) : (0..9)
    unless valid_range.include?(score)
      errors.add(:score, "must be between #{valid_range.min} and #{valid_range.max}")
    end
  end
end
