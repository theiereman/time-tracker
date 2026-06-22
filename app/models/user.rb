class User < ApplicationRecord
  include User::MagicLinkable
  include User::Setupable

  has_many :activity_categories, class_name: "Activity::Category", dependent: :destroy
  has_many :activities

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  after_create -> { Activity::Category.create_default_categories_for(self) }

  def last_activity
    activities.order(started_at: :desc).first
  end

  def first_datetime_of_day
    current_date = Date.current
    DateTime.new(current_date.year, current_date.month, current_date.day, wake_up_hour)
  end

  def sleep_duration_in_hours
    HOURS_IN_A_DAY - awake_duration_in_hours
  end

  def awake_duration_in_hours
    sleep_hour - wake_up_hour
  end

  def number_of_activities_in_a_day
    Activity::HOURS_IN_A_DAY / Activity::DURATION_IN_HOURS
  end
end
