module User::Setupable
  extend ActiveSupport::Concern

  DEFAULT_WAKE_UP_HOUR = 7
  DEFAULT_SLEEP_HOUR = 23

  included do
    before_validation :set_default_values

    store :settings, accessors: [ :sleep_hour, :wake_up_hour ]

    def wake_up_hour = super.to_i
    def sleep_hour = super.to_i

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
