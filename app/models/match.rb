class Match < ApplicationRecord
  DEFAULT_STAGE_BETTING_CUTOFF = 12.hours

  belongs_to :stage

  has_one :event, through: :stage

  has_many :match_participants, dependent: :destroy, inverse_of: :match
  has_many :participants, through: :match_participants
  has_many :results, through: :match_participants, dependent: :destroy
  has_many :predictions, dependent: :destroy

  enum :match_status, { unset: 0, bets_open: 1, bets_closed: 2, in_progress: 3, finished: 4 }, allow_nil: true
  enum :match_type, { one_on_one: 0, multi_nominee: 1 }

  validates :match_date, presence: true
  validates :round, presence: true, numericality: { greater_than: 0 }

  accepts_nested_attributes_for :match_participants, allow_destroy: true

  before_validation :assign_lifecycle_status
  before_save :assign_default_name

  scope :by_event, ->(event) { where(event_id: event) }
  scope :bets_open, -> { where(match_status: :bets_open) }
  scope :bets_closed_or_later, -> { where(match_status: [ :bets_closed, :in_progress, :finished ]) }

  def display_name
    name.presence || generated_display_name
  end

  def outcome
    return nil unless finished?

    scores = results.pluck(:match_participant_id, :score).to_h
    return nil if scores.empty?

    if multi_nominee?
      # Multi-nominee: winner has score=1, others have score=0
      winner = scores.find { |_, score| score == 1 }
      winner&.first
    else
      # One-on-one: highest score wins, ties = draw
      max_score = scores.values.max
      winners = scores.select { |_, score| score == max_score }
      winners.count > 1 ? :draw : winners.keys.first
    end
  end

  def allows_draw?
    one_on_one?
  end

  def mark_as_final!
    transaction do
      update!(match_status: :finished)
      score_all_predictions!
    end
  end

  def assign_lifecycle_status
    return if in_progress? || finished?

    if match_started_by_policy?
      self.match_status = :in_progress
      return
    end

    if betting_closed_by_policy?
      self.match_status = :bets_closed
      return
    end

    self.match_status = participants_ready? ? :bets_open : :unset
  end

  private

  def assign_default_name
    self.name ||= generated_display_name
  end

  def generated_display_name
    return nil if participants.empty?

    if multi_nominee?
      participants.map(&:name).join(", ")
    else
      participants.map(&:name).join(" vs. ")
    end
  end

  def match_started_by_policy?
    match_date && match_date <= Time.current
  end

  def score_all_predictions!
    predictions.find_each do |prediction|
      prediction.calculate_score!
    end
  end

  def betting_closed_by_policy?
    stage_betting_cutoff_time <= Time.current
  end

  def stage_betting_cutoff_time
    return nil unless effective_stage_start_time

    effective_stage_start_time - DEFAULT_STAGE_BETTING_CUTOFF
  end

  def participants_ready?
    match_participants.reject(&:marked_for_destruction?).size >= 2
  end

  def effective_stage_start_time
    times = [ stage.persisted_start_time, match_date ].compact
    times.min
  end
end
