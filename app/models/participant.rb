class Participant < ApplicationRecord
  has_many :match_participants
  has_many :matches, through: :match_participants

  has_one_attached :image
end
