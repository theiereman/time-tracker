class Activity < ApplicationRecord
  DURATION_IN_HOURS = 1

  before_validation :defaults

  belongs_to :category, class_name: "Activity::Category", foreign_key: "activity_category_id"
  has_one :user, through: :category, validate: true

  validates :started_at, :category, presence: true
  validate :unique_on_timespan_for_user, on: :create

  scope :today, -> { where(started_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :at, ->(date) { where(started_at: date.beginning_of_day..date.end_of_day) }

  private

  def defaults
    return if started_at.nil?
    self.ended_at ||= started_at&.to_datetime + DURATION_IN_HOURS.hour

    self.started_at = self.started_at.beginning_of_hour
    self.ended_at = self.ended_at.beginning_of_hour
  end

  def unique_on_timespan_for_user
    end_timedate = started_at.to_datetime + DURATION_IN_HOURS.hour
    return unless user.activities.where(started_at: started_at...end_timedate).any?

    errors.add(:base, "Une activité exsite déjà pour cette période.")
  end
end
