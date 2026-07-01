module User::Setupable
  extend ActiveSupport::Concern

  DEFAULT_WAKE_UP_HOUR = 7
  DEFAULT_SLEEP_HOUR = 23

  AVAILABLE_ACTIVITY_DURATIONS = [ 15, 30, 60 ]

  included do
    before_validation :set_default_values

    store :settings, accessors: [ :sleep_hour, :wake_up_hour, :locale, :activity_duration_in_minutes ]

    validates :activity_duration_in_minutes, inclusion: { in: AVAILABLE_ACTIVITY_DURATIONS }

    def wake_up_hour = super.to_i
    def sleep_hour = super.to_i

    def night?(hour)
      hour > sleep_hour || hour < wake_up_hour
    end

    def sleep_hours
      24.times.select { night?(it) }
    end

    def activity_duration_in_minutes
      (super || 60).to_i
    end

    def snap_to_activity_slot(time)
      index = ((time - time.beginning_of_day) / 60 / activity_duration_in_minutes).floor
      time.beginning_of_day + (index * activity_duration_in_minutes).minutes
    end

    private

    def set_default_values
      return if sleep_schedule_setup?

      self.wake_up_hour = DEFAULT_WAKE_UP_HOUR
      self.sleep_hour = DEFAULT_SLEEP_HOUR
    end

    def sleep_schedule_setup?
      !self.wake_up_hour.zero? && !self.sleep_hour.zero?
    end
  end
end
