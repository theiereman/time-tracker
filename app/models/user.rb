class User < ApplicationRecord
  include User::MagicLinkable

  has_many :sessions, dependent: :destroy
  has_many :activity_categories, class_name: "Activity::Category", dependent: :destroy
  has_many :activities, through: :activity_categories

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true,
  format: { with: URI::MailTo::EMAIL_REGEXP }

  def next_activity_start_datetime
    latest_activity = activities.order(started_at: :desc).first
    latest_activity_end_datetime = latest_activity&.ended_at
    return default_start_datetime if latest_activity_end_datetime.nil?

    next_datetime = latest_activity_end_datetime.to_datetime
    return latest_activity.started_at if next_datetime.to_date >= Date.current

    if next_datetime.hour >= sleep_hour
      next_datetime = next_datetime.change({ day: latest_activity_end_datetime.day + 1, hour: wake_up_hour })
    end

    next_datetime
  end

  def latest_activity_for(date)
    activities.select { |activity| activity.started_at.to_date == date }.max_by(&:started_at)
  end

  def has_done_every_activity_for(date)
    remaining_activities_for(date) == 0
  end

  def remaining_activities_for(date)
    total_number_of_activities_in_a_day - number_of_activities_for(date)
  end

  def total_number_of_activities_in_a_day
    awake_duration_in_hours / Activity.duration_in_hours
  end

  def number_of_activities_for(date)
    activities.select { |activity| activity.started_at.to_date == date }.count
  end

  def remaining_hours_for(date)
    hours = 24 - sleep_duration_in_hours - activities.select { |activity| activity.started_at.to_date == date }.sum(&:duration_in_hours)
    hours % 1 == 0 ? hours.to_i : hours
  end

  def default_start_datetime = DateTime.current.change({ hour: wake_up_hour })
  def wake_up_hour = 7
  def sleep_hour = 23
  def awake_duration_in_hours = sleep_hour - wake_up_hour
  def sleep_duration_in_hours = 24 - awake_duration_in_hours
end
