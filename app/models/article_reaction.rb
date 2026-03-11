class ArticleReaction < ApplicationRecord
  belongs_to :article
  belongs_to :profile

  validates :value, inclusion: { in: [1, -1] }
  validates :profile_id, uniqueness: { scope: [:article_id, :segment_index] }
end
