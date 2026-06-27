class Sessions::MagicLinksController < ApplicationController
  require_unauthenticated_access
  rate_limit to: 10, within: 15.minutes, only: :create, with: :rate_limit_exceeded
  before_action :ensure_email_address_pending_authentication
  layout "sessions"

  def new
  end

  # Enter the code: consume the matching magic link and start a session.
  def create
    if magic_link = MagicLink.consume(code)
      authenticate magic_link
    else
      invalid_code
    end
  end

  private
    def code
      params.expect(:code)
    end

    def ensure_email_address_pending_authentication
      unless email_address_pending_authentication.present?
        redirect_to new_session_path, alert: "Entrez votre addresse mail pour vous connecter."
      end
    end

    def authenticate(magic_link)
      if ActiveSupport::SecurityUtils.secure_compare(email_address_pending_authentication, magic_link.user.email_address)
        sign_in magic_link
      else
        email_address_mismatch
      end
    end

    def sign_in(magic_link)
      clear_pending_authentication_token
      start_new_session_for magic_link.user
      redirect_to after_authentication_url
    end

    def email_address_mismatch
      clear_pending_authentication_token
      redirect_to new_session_path, alert: "Une erreur est survenue. Veuillez réessayer."
    end

    def invalid_code
      redirect_to new_session_magic_link_path, alert: "Le code est invalide ou expiré. Veuillez réessayer."
    end

    def rate_limit_exceeded
      redirect_to new_session_magic_link_path, alert: "Trop de tentatives. Veuillez réessayer dans 15 minutes."
    end
end
