class SessionsController < ApplicationController
  require_unauthenticated_access except: :destroy
  rate_limit to: 10, within: 3.minutes, only: :create, with: :rate_limit_exceeded

  def new
  end

  # Enter an email address: send a magic link code and move on to the code page.
  def create
    user = User.find_by(email_address: email_address) || create_user

    if user&.persisted?
      magic_link = user.send_magic_link(for: user.previously_new_record? ? :sign_up : :sign_in)
      set_pending_authentication_token magic_link
      redirect_to new_session_magic_link_path, notice: "Un code a été envoyé à #{email_address}."
    elsif user.nil?
      redirect_to new_session_path, alert: "Une erreur est survenue lors de la création de l'utilisateur."
    else
      redirect_to new_session_path, alert: "Entrez un email valide."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "Vous avez été déconnecté."
  end

  private
    def email_address
      params.expect(:email_address)
    end

    def create_user
      User.create(email_address: email_address)
    rescue ActiveRecord::RecordInvalid
      nil
    end

    def rate_limit_exceeded
      redirect_to new_session_path, alert: "Trop de requêtes. Rééssayez plus tard."
    end
end
