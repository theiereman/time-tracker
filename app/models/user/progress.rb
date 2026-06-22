class User::Progress
  attr_reader :user, :activities, :schedule

  delegate :number_of_activities_in_a_day, to: :schedule

  private def initialize(user, schedule, range)
    @user = user
    @schedule = schedule
    @range = range
  end

  def self.for_the_day(user, schedule, date = Date.current)
    new(user, schedule, date.beginning_of_day..date.end_of_day)
  end

  def self.for_the_month(user, schedule, date = Date.current)
    new(user, schedule, date.beginning_of_month..date.end_of_month)
  end

  def all_activities_done?(date: nil)
    return activities.size == number_of_activities_in_a_day if date.nil?
    return false if activities_per_day[date].nil?

    activities_per_day[date].count == number_of_activities_in_a_day
  end

  def remaining_activities_count
    number_of_activities_in_a_day - activities.size
  end

  def activities_per_day
    @apd ||= activities.each_with_object({}) do |a, h|
      h[a.started_at.to_date] ||= []
      h[a.started_at.to_date] << a
    end
  end

  def activities
    @activities ||= @user.activities
                         .where(started_at: @range)
                         .includes(:category)
                         .to_a
  end
end
