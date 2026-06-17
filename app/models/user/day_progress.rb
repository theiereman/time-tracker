class User::DayProgress
  attr_reader :user, :activities, :schedule

  def initialize(user, schedule)
    @user = user
    @schedule = schedule
  end

  def self.daily(user:, schedule:, date:)
    new(user, schedule, date.beginning_of_day..date.end_of_day)
  end

  def all_activities_done?
    activities.size == total_activities_count
  end

  def remaining_activities_count
    total_activities_count - activities.size
  end

  def total_activities_count
    @schedule.number_of_activities_in_a_day
  end

  def activities
    @activities ||= @user.activities
                         .where(started_at: Date.current.beginning_of_day...Date.current.end_of_day)
                         .includes(:category)
                         .to_a
  end
end
