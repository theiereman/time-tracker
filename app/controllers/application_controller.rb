class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_action_and_controller_names
  around_action :switch_locale

  private

  def set_action_and_controller_names
    Current.path = request.path
    Current.action = action_name
    Current.controller = controller_name
  end

  def switch_locale(&action)
    I18n.with_locale(locale_for_request, &action)
  end

  # User preference wins; otherwise fall back to the browser's Accept-Language,
  # then to the application default locale.
  def locale_for_request
    user_locale = Current.user&.locale.presence&.to_sym
    return user_locale if user_locale && I18n.available_locales.include?(user_locale)

    locale_from_header || I18n.default_locale
  end

  def locale_from_header
    request.env["HTTP_ACCEPT_LANGUAGE"].to_s
      .scan(/[a-z]{2}/i)
      .map { |code| code.downcase.to_sym }
      .find { |code| I18n.available_locales.include?(code) }
  end
end
