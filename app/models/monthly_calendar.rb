class MonthlyCalendar
  attr_reader :month, :days, :date

  def initialize(progress, date)
    @progress = progress
    @date = date
    init_days
  end

  def days_count
    Time.days_in_month(@date.month)
  end

  def weeks_count
    days_count/ 7.round
  end

  def completed_activities_count
    activities.count
  end

  def activities
    @progress.activities
  end

  def init_days
    @days = []
    days_count.times do |i|
      date = Date.new(@date.year, @date.month, i+1)
      @days << Day.new(date, @progress.all_activities_done?(date:), Activity.number_of_activities_in_a_day, @progress.remaining_activities_count(date:))
    end
  end
end
