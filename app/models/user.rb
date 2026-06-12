class User < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :magic_links, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }

  # Creates a magic link for this user and emails the code to them.
  # Mirrors fizzy's Identity#send_magic_link.
  def send_magic_link(**attributes)
    attributes[:purpose] = attributes.delete(:for) if attributes.key?(:for)

    magic_links.create!(attributes).tap do |magic_link|
      MagicLinkMailer.sign_in_instructions(magic_link).deliver_later
    end
  end
end
