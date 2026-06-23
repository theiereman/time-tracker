class CalendarsController < ApplicationController
  def show
    @date = begin
      params[:date]&.to_date&.beginning_of_month || Date.current
    rescue Date::Error
      Date.current
    end
    @progress = User::Progress.for_the_month(Current.user, @date)
    @calendar = MonthlyCalendar.new(@progress, @date)
  end
end
