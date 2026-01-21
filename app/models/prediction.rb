class Prediction < ApplicationRecord
  belongs_to :betting_pool
  belongs_to :match
  belongs_to :user

  has_many :predicted_results, dependent: :destroy

  validates :predicted_score1, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :predicted_score2, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: [ :betting_pool_id, :match_id ], message: "already made a prediction for this match in this pool" }
  validate :match_must_be_upcoming

  scope :by_user, ->(user) { where(user: user) }
  scope :by_pool, ->(pool) { where(betting_pool: pool) }
  scope :by_match, ->(match) { where(match: match) }

  def correct_score?
    return false unless match.completed?

    predicted_score1 == match.score1 && predicted_score2 == match.score2
  end

  def correct_outcome?
    return false unless match.completed?

    predicted_winner == match.winner
  end

  def predicted_winner
    return :draw if predicted_score1 == predicted_score2
    return match.team1 if predicted_score1 > predicted_score2
    match.team2
  end

  def points_earned
    return 0 unless match.completed?

    points = 0
    points += 3 if correct_score?
    points += 1 if correct_outcome? && !correct_score?
    points
  end

  private

  def match_must_be_upcoming
    if match.present? && !match.upcoming?
      errors.add(:base, "Predictions can only be made for upcoming matches")
    end
  end
end
