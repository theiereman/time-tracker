class User::Schedule
  HOURS_IN_A_DAY = 24

  def initialize(user)
    @user = user
  end

  delegate :wake_up_hour, to: :@user
  delegate :sleep_hour, to: :@user

  def first_datetime_of_day
    current_date = Date.current
    DateTime.new(current_date.year, current_date.month, current_date.day, wake_up_hour)
  end

  def sleep_duration_in_hours
    HOURS_IN_A_DAY - awake_duration_in_hours
  end

  def awake_duration_in_hours
    @user.sleep_hour - @user.wake_up_hour
  end

  def number_of_activities_in_a_day
    awake_duration_in_hours / Activity::DURATION_IN_HOURS
  end

  private

  def activities
    @activities ||= @user.activities
  end
end
