class Match < ApplicationRecord
  belongs_to :event
  belongs_to :team1, class_name: "Team", optional: true
  belongs_to :team2, class_name: "Team", optional: true

  has_many :predictions, dependent: :destroy

  validates :match_date, presence: true
  validates :round, presence: true, numericality: { greater_than: 0 }
  validates :score1, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :score2, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :teams_must_be_different

  scope :upcoming, -> { where("match_date > ?", Time.current) }
  scope :completed, -> { where.not(score1: nil).where.not(score2: nil) }
  scope :by_event, ->(event) { where(event_id: event) }

  def teams_set?
    team1.present? && team2.present?
  end

  def completed?
    score1.present? && score2.present?
  end

  def upcoming?
    match_date > Time.current
  end

  def winner
    return nil unless completed?
    return :draw if score1 == score2
    return team1 if score1 > score2
    team2
  end

  private

  def teams_must_be_different
    if team1.present? && team2.present? && team1_id == team2_id
      errors.add(:team2, "must be different from team1")
    end
  end
end
