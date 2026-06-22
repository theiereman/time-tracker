class User < ApplicationRecord
  include User::MagicLinkable
  include User::Setupable

  has_many :activity_categories, class_name: "Activity::Category", dependent: :destroy
  has_many :activities

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  after_create -> { Activity::Category.create_default_categories_for(self) }
end
