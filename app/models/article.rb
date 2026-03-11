class Article < ApplicationRecord
  acts_as_taggable_on :tags

  has_many :article_reactions, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  validates :title, :content, :slug, presence: true
  validates :slug, uniqueness: true

  scope :published, -> { where("published_at <= ?", Time.current).order(published_at: :desc) }

  def to_param
    slug
  end

  def segments
    content.strip.split(/\n\s*\n/).map(&:strip).reject(&:blank?)
  end

  def segment_scores
    counts = article_reactions.group(:segment_index).select(
      :segment_index,
      Arel.sql("SUM(CASE WHEN value = 1 THEN 1 ELSE 0 END) AS likes_count"),
      Arel.sql("SUM(CASE WHEN value = -1 THEN 1 ELSE 0 END) AS dislikes_count"),
      Arel.sql("COUNT(*) AS total_count")
    ).index_by(&:segment_index)

    segments.each_with_index.map do |_text, i|
      row = counts[i]
      if row
        { likes: row.likes_count.to_i, dislikes: row.dislikes_count.to_i, total: row.total_count.to_i }
      else
        { likes: 0, dislikes: 0, total: 0 }
      end
    end
  end
end
