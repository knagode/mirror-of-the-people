class Wish < ApplicationRecord
  has_many :matches, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :parties, through: :matches

  validates :content, presence: true
end
