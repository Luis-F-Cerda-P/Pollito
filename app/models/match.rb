class Match < ApplicationRecord
  DEFAULT_STAGE_BETTING_CUTOFF = 12.hours

  belongs_to :stage

  has_one :event, through: :stage

  has_many :match_participants, dependent: :destroy, inverse_of: :match
  has_many :participants, through: :match_participants
  has_many :results, through: :match_participants, dependent: :destroy
  has_many :predictions, dependent: :destroy
  # TODO: match_status should be programatically set, where:
  # an 'unset' has one or less participants, like a quarter final fixture where there's a peding match to determine the second team;
  # a 'set' match has all its participants determined (2 or more), but match_date is still in the future;
  # an 'ongoing' match has a 'match_date' in the past and either is missing Result records, or those result records are not 'final'
  # (at the time of time of this comment, the Result model is planned but not yet implemented, so the 'final' flag on them could eventually not exist);
  # a 'finished' match is done, closed for modification
  enum :match_status, { unset: 0, bets_open: 1, bets_closed: 2, in_progress: 3, finished: 4 }, allow_nil: true
  enum :match_type, { one_on_one: 0, multi_nominee: 1 }

  validates :match_date, presence: true
  validates :round, presence: true, numericality: { greater_than: 0 }

  accepts_nested_attributes_for :match_participants, allow_destroy: true

  before_validation :assign_lifecycle_status

  scope :by_event, ->(event) { where(event_id: event) }
  scope :bets_open, -> { where(match_status: :bets_open) }
  scope :bets_closed_or_later, -> { where(match_status: [ :bets_closed, :in_progress, :finished ]) }

  def display_name
    participants.map(&:name).join(" vs. ")
  end

  def outcome
    return nil unless finished?

    scores = results.pluck(:match_participant_id, :score).to_h
    return nil if scores.empty?

    max_score = scores.values.max
    winners = scores.select { |_, score| score == max_score }

    winners.count > 1 ? :draw : winners.keys.first
  end

  def mark_as_final!
    transaction do
      update!(match_status: :finished)
      score_all_predictions!
    end
  end

  def assign_lifecycle_status
    return if in_progress? || finished?

    if betting_closed_by_policy?
      self.match_status = :bets_closed
      return
    end

    self.match_status =
      participants_ready? ? :bets_open : :unset
  end

  private

  def score_all_predictions!
    predictions.find_each do |prediction|
      prediction.calculate_score!
    end
  end

  def betting_closed_by_policy?
    stage_betting_cutoff_time <= Time.current
  end

  def stage_betting_cutoff_time
    stage.start_time - DEFAULT_STAGE_BETTING_CUTOFF
  end
end
