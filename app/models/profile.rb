class Profile < ApplicationRecord
  belongs_to :user, optional: true
  has_many :wishes, dependent: :destroy

  before_create :generate_token

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(16)
  end
end
