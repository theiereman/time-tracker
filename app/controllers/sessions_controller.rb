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
      redirect_to new_session_magic_link_path, notice: "We emailed a code to #{email_address}."
    else
      redirect_to new_session_path, alert: "Enter a valid email address."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "You have been signed out."
  end

  private
    def email_address
      params.expect(:email_address)
    end

    def create_user
      User.create(email_address: email_address)
    end

    def rate_limit_exceeded
      redirect_to new_session_path, alert: "Too many attempts. Try again later."
    end
end
