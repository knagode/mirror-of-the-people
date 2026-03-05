class Vote < ApplicationRecord
  belongs_to :wish

  validates :value, inclusion: { in: [1, -1] }
  validates :session_id, uniqueness: { scope: :wish_id }
end
