class Prediction < ApplicationRecord
  belongs_to :betting_pool
  belongs_to :match
  belongs_to :user

  has_many :predicted_results, dependent: :destroy

  validates :user_id, uniqueness: { scope: [ :betting_pool_id, :match_id ] }

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
