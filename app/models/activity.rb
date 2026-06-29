class Activity < ApplicationRecord
  HOURS_IN_A_DAY = 24
  DURATION_IN_HOURS = 1

  after_initialize :defaults

  belongs_to :category, class_name: "Activity::Category", foreign_key: "activity_category_id"
  belongs_to :user

  validates :user, presence: true
  validates :started_at, :category, presence: true
  validate :unique_on_timespan_for_user, on: :create
  validate :present_or_past

  scope :today, -> { where(started_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :at, ->(date) { where(started_at: date.beginning_of_day..date.end_of_day) }

  def self.number_of_activities_in_a_day
    HOURS_IN_A_DAY / DURATION_IN_HOURS
  end

  private

  def defaults
    return if started_at.nil?
    self.ended_at ||= started_at + DURATION_IN_HOURS.hour

    self.started_at = self.started_at.beginning_of_hour
    self.ended_at = self.ended_at.beginning_of_hour
  end

  def unique_on_timespan_for_user
    end_timedate = started_at + DURATION_IN_HOURS.hour
    return unless user.activities.where(started_at: started_at...end_timedate).any?

    errors.add(:base, :already_exists)
  end

  def present_or_past
    return if started_at.to_date <= Date.current

    errors.add(:started_at, :future)
  end
end
