class CalendarsController < ApplicationController
  def show
    user = Current.user
    @progress = User::Progress.for_the_month(user, User::Schedule.new(user), Date.current)
    @calendar = MonthlyCalendar.new(@progress, Date.current.month)
  end
end
