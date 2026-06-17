class User::ActivitySlot
  def initialize(activities, schedule)
    @activities = activities
    @schedule = schedule
  end

  def get_next
    latest_activity = @activities.order(started_at: :desc).first
    latest_activity_end_datetime = latest_activity&.ended_at
    return DateTime.current.change({ hour: @schedule.wake_up_hour }) if latest_activity_end_datetime.nil?

    next_datetime = latest_activity_end_datetime.to_datetime
    return latest_activity.started_at if next_datetime.to_date > Date.current || (next_datetime.to_date == Date.current && next_datetime.hour >= @schedule.sleep_hour)

    if next_datetime.hour >= @schedule.sleep_hour
      next_datetime = (next_datetime + 1.day).change({ hour: @schedule.wake_up_hour })
    end

    next_datetime
  end
end
