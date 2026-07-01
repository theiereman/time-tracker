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
    slots_per_day = @progress.slot_count
    days_count.times do |i|
      date = Date.new(@date.year, @date.month, i+1)
      filled = @progress.filled_slots_on(date)
      @days << Day.new(date, filled >= slots_per_day, filled, slots_per_day)
    end
  end
end
