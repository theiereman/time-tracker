class SessionsController < ApplicationController
  require_unauthenticated_access except: :destroy
  rate_limit to: 10, within: 3.minutes, only: :create, with: :rate_limit_exceeded

  def new
  end

  def create
    user = User.find_by(email_address: email_address) || create_user

    if user&.persisted?
      magic_link = user.send_magic_link(for: user.previously_new_record? ? :sign_up : :sign_in)
      set_pending_authentication_token magic_link
      redirect_to new_session_magic_link_path
    elsif user.nil?
      redirect_to new_session_path, alert: t("sessions.flash.user_creation_failed")
    else
      redirect_to new_session_path, alert: t("sessions.flash.invalid_email")
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: t("sessions.flash.signed_out")
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
      redirect_to new_session_path, alert: t("sessions.flash.rate_limited")
    end
end
