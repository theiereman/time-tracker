class User < ApplicationRecord
  include User::MagicLinkable

  has_many :sessions, dependent: :destroy
  has_many :activity_categories, class_name: "Activity::Category", dependent: :destroy
  has_many :activities, through: :activity_categories

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
