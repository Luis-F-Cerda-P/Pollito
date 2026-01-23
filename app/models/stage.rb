class Stage < ApplicationRecord
  belongs_to :event

  has_many :matches, dependent: :destroy

  validates :name, presence: true
end
