class Vote < ApplicationRecord
  belongs_to :wish
  belongs_to :profile

  validates :value, inclusion: { in: [1, -1] }
  validates :profile_id, uniqueness: { scope: :wish_id }
end
