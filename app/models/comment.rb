class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :wish, optional: true
  belongs_to :profile

  validates :content, presence: true
end
