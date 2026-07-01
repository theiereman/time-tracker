class UserProfileLink < ApplicationRecord
  TOKEN_LENGTH = 24
  MAX_TOKEN_GENERATION_ATTEMPTS = 5

  class TokenGenerationError < StandardError; end

  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :user_id, uniqueness: true

  before_validation :generate_token, on: :create

  class << self
    def find_or_create_for(user)
      find_by(user: user) || create!(user: user)
    end

    def generate_unique_token
      MAX_TOKEN_GENERATION_ATTEMPTS.times do
        candidate = SecureRandom.urlsafe_base64(TOKEN_LENGTH)
        return candidate unless exists?(token: candidate)
      end

      raise TokenGenerationError, "Could not generate a unique token after #{MAX_TOKEN_GENERATION_ATTEMPTS} attempts"
    end
  end

  def regenerate!
    update!(token: self.class.generate_unique_token)
  end

  private
    def generate_token
      self.token ||= self.class.generate_unique_token
    end
end
