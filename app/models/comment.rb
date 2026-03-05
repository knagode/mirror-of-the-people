class Comment < ApplicationRecord
  belongs_to :wish
  belongs_to :profile

  validates :content, presence: true
end
