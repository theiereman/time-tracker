class Activity < ApplicationRecord
  MINUTES_IN_A_DAY = 1440
  DEFAULT_DURATION_IN_MINUTES = 60

  belongs_to :category, class_name: "Activity::Category", foreign_key: "activity_category_id"
  belongs_to :user

  before_validation :set_slot_bounds

  validates :user, presence: true
  validates :started_at, :category, presence: true
  validate :no_overlap_for_user, on: :create
  validate :present_or_past

  scope :today, -> { where(started_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :at, ->(date) { where(started_at: date.beginning_of_day..date.end_of_day) }
  scope :overlapping, ->(starts_at, ends_at) { where("started_at < ? AND ended_at > ?", ends_at, starts_at) }

  def duration_in_minutes
    user&.activity_duration_in_minutes || DEFAULT_DURATION_IN_MINUTES
  end

  private

  def set_slot_bounds
    return if started_at.nil?

    self.started_at = user ? user.snap_to_activity_slot(started_at) : started_at.beginning_of_hour
    self.ended_at = started_at + duration_in_minutes.minutes if start_moved?
  end

  def start_moved?
    new_record? || started_at_changed?
  end

  def overlapping_activities
    scope = user.activities.overlapping(started_at, ended_at)
    persisted? ? scope.where.not(id: id) : scope
  end

  def no_overlap_for_user
    return if started_at.nil? || ended_at.nil?

    errors.add(:base, :already_exists) if overlapping_activities.exists?
  end

  def present_or_past
    return if started_at.nil? || started_at.to_date <= Date.current

    errors.add(:started_at, :future)
  end
end
