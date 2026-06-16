class Activity < ApplicationRecord
  after_initialize :defaults

  belongs_to :category, class_name: "Activity::Category", foreign_key: "activity_category_id"
  has_one :user, through: :category

  validates :started_at, :category, presence: true
  validate :user_has_not_finished_day

  scope :today, -> { where(started_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :at, ->(date) { where(started_at: date.beginning_of_day..date.end_of_day) }

  def self.duration_in_hours = 1

  def duration_in_hours
    ((ended_at - started_at) / 1.hour).round(2)
  end

  private

  def defaults
    return if started_at.nil?
    self.ended_at ||= started_at&.to_datetime + 1.hour

    self.started_at = self.started_at.beginning_of_hour
    self.ended_at = self.ended_at.beginning_of_hour
  end

  def user_has_not_finished_day
    return true unless user&.has_done_every_activity_for(started_at&.to_date)

    errors.add(:base, "L'utilisateur a déjà rempli tous les activités pour aujourd'hui")
    false
  end
end
