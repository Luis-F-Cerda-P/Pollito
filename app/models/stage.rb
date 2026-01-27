class Stage < ApplicationRecord
  belongs_to :event

  has_many :matches, dependent: :destroy

  validates :name, presence: true

  def persisted_start_time
    matches.minimum(:match_date)
  end
end
