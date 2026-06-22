class MonthlyCalendar
  attr_reader :month, :days

  def initialize(progress, month)
    @progress = progress
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
    @progress.activities
  end

  def init_days
    @days = []
    days_count_for_month.times do |i|
      date = Date.new(Date.current.year, @month, i+1)
      @days << Calendar::Day.new(date, @progress.all_activities_done?(date:))
    end
  end
end
