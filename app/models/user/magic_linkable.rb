module User::MagicLinkable
  extend ActiveSupport::Concern

  included do
    has_many :sessions, dependent: :destroy
    has_many :magic_links, dependent: :destroy

    def send_magic_link(**attributes)
      attributes[:purpose] = attributes.delete(:for) if attributes.key?(:for)

      magic_links.create!(attributes).tap do |magic_link|
        MagicLinkMailer.sign_in_instructions(magic_link).deliver_later
      end
    end
  end
end
