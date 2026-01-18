class Team < ApplicationRecord
  has_many :matches_as_team1, class_name: "Match", foreign_key: :team1_id, dependent: :nullify
  has_many :matches_as_team2, class_name: "Match", foreign_key: :team2_id, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :country_code, presence: true, uniqueness: true, format: { with: /\A[A-Z]{2,3}\z/, message: "should be 2-3 uppercase letters" }

  def matches
    Match.where("team1_id = ? OR team2_id = ?", id, id)
  end
end
