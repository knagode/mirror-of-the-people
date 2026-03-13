class Wish < ApplicationRecord
  acts_as_taggable_on :tags
  has_neighbors :embedding

  scope :visible, -> { where(is_ignored: false) }
  scope :with_embedding, -> { where.not(embedding: nil) }

  belongs_to :profile, optional: true
  belongs_to :ai_summary, optional: true
  has_many :matches, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :parties, through: :matches

  validates :content, presence: true

  MAX_COSINE_DISTANCE = ENV["MAX_COSINE_DISTANCE"]&.to_f || 100

  def similar_wishes(limit: 5)
    return [] unless embedding.present?
    nearest_neighbors(:embedding, distance: "cosine")
      .visible
      .limit(limit)
      .select { |w| w.neighbor_distance <= MAX_COSINE_DISTANCE }
  end
end
