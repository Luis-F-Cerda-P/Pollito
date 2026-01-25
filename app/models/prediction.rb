class Prediction < ApplicationRecord
  include Scorable

  belongs_to :betting_pool
  belongs_to :match
  belongs_to :user

  has_many :predicted_results, dependent: :destroy

  validates :user_id, uniqueness: { scope: [ :betting_pool_id, :match_id ] }

  accepts_nested_attributes_for :predicted_results

  def predicted_outcome
    scores = predicted_results.pluck(:match_participant_id, :score).to_h
    return nil if scores.empty?

    max_score = scores.values.max
    winners = scores.select { |_, score| score == max_score }

    winners.count > 1 ? :draw : winners.keys.first
  end

  def self.create_for_match!(user:, betting_pool:, match:, scores:)
    transaction do
      prediction = create!(
        user: user,
        betting_pool: betting_pool,
        match: match
      )

      match.match_participants.find_each do |mp|
        prediction.predicted_results.create!(
          match_participant: mp,
          score: scores.fetch(mp.participant_id)
        )
      end

      prediction
    end
  end
end
