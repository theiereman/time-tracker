class SettingsController < ApplicationController
  before_action :set_user

  def index
  end

  def update
    if @user.update(user_params)
      redirect_to settings_path, notice: t("settings.flash.updated")
    else
      redirect_to settings_path, alert: @user.errors.full_messages.first
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def user_params
    params.expect(user: [ :activity_duration_in_minutes, :wake_up_hour, :sleep_hour, :locale ])
  end
end
