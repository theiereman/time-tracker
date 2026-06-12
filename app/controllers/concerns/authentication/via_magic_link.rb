module Authentication::ViaMagicLink
  extend ActiveSupport::Concern

  included do
    helper_method :email_address_pending_authentication
  end

  private
    # Email address stored (cryptographically signed) while the user waits to
    # enter their code, so the code is only accepted in the browser that
    # requested it. Mirrors fizzy's pending authentication token.
    def email_address_pending_authentication
      pending_authentication_token_verifier.verified(pending_authentication_token)
    end

    def set_pending_authentication_token(magic_link)
      cookies[:pending_authentication_token] = {
        value: pending_authentication_token_verifier.generate(
          magic_link.user.email_address, expires_at: magic_link.expires_at
        ),
        httponly: true,
        same_site: :lax,
        expires: magic_link.expires_at
      }
    end

    def clear_pending_authentication_token
      cookies.delete(:pending_authentication_token)
    end

    def pending_authentication_token
      cookies[:pending_authentication_token]
    end

    def pending_authentication_token_verifier
      Rails.application.message_verifier(:pending_authentication)
    end
end
