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

  def all_activities_done?(date: nil)
    return activities.size >= Activity.number_of_activities_in_a_day if date.nil?
    return false if activities_per_day[date].nil?

    activities_per_day[date].count >= Activity.number_of_activities_in_a_day
  end

  def remaining_activities_count(date:)
    [ Activity.number_of_activities_in_a_day - activities.select { it.started_at.between?(date.beginning_of_day, date.end_of_day) }.size, 0 ].max
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
