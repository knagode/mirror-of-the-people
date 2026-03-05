class Wish < ApplicationRecord
  belongs_to :profile, optional: true
  has_many :matches, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :parties, through: :matches

  validates :content, presence: true
end
