class User::Schedule
  HOURS_IN_A_DAY = 24

  def initialize(user)
    @user = user
  end

  def wake_up_hour = 7 # TODO: make this alterable in user app settings
  def sleep_hour = 23 # TODO: make this alterable in user app settings

  def sleep_duration_in_hours
    HOURS_IN_A_DAY - awake_duration_in_hours
  end

  def awake_duration_in_hours
    sleep_hour - wake_up_hour
  end

  def number_of_activities_in_a_day
    awake_duration_in_hours / Activity::DURATION_IN_HOURS
  end

  private

  def activities
    @activities ||= @user.activities
  end
end
