class Party < ApplicationRecord
  has_many :matches, dependent: :destroy

  validates :name, presence: true
  validates :program, presence: true
end
