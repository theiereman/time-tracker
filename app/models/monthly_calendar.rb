class MonthlyCalendar
  attr_reader :month, :days

  def initialize(activities_progress, month)
    @activities_progress = activities_progress
    @month = month
    init_days
  end

  def days_count_for_month
    Time.days_in_month(@month)
  end

  def completed_activities_count
    activities.count
  end

  def activities
    @activities_progress.activities
  end

  def init_days
    @days = []
    days_count_for_month.times do |i|
      date = Date.new(Date.current.year, @month, i+1)
      @days << Calendar::Day.new(date, @activities_progress.all_activities_done?(date:))
    end
  end
end
