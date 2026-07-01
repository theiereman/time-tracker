class User::Progress
  attr_reader :user, :activities

  private def initialize(user, range)
    @user = user
    @range = range
  end

  def self.for_the_day(user, date = Date.current)
    new(user, date.beginning_of_day..date.end_of_day)
  end

  def self.for_the_month(user, date = Date.current)
    new(user, date.beginning_of_month.beginning_of_day..date.end_of_month.end_of_day)
  end

  def date
    @range.begin.to_date
  end

  def slot_count
    Activity::MINUTES_IN_A_DAY / user.activity_duration_in_minutes
  end

  def filled_slots_on(day)
    slots_for(day).count { |_starts_at, activity| activity }
  end

  def all_activities_done?(date: nil)
    filled_slots_on(date || self.date) >= slot_count
  end

  def remaining_activities_count(date:)
    [ slot_count - filled_slots_on(date), 0 ].max
  end

  def slots_for(day)
    duration = user.activity_duration_in_minutes
    day_start = Time.zone.local(day.year, day.month, day.day)
    acts = activities_per_day[day] || []

    (0...(Activity::MINUTES_IN_A_DAY / duration)).map do |i|
      starts_at = day_start + (i * duration).minutes
      activity = acts.find { |a| a.started_at <= starts_at && a.ended_at > starts_at }
      [ starts_at, activity ]
    end
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
