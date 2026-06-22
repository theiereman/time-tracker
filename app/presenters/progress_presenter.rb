class ProgressPresenter
  delegate_missing_to :@progress

  Slot = Data.define(:hour, :activity) do
    def filled? = activity.present?
    def label = filled? ? activity.category.label : "Non renseigné"
  end

  def initialize(progress)
    @progress = progress
  end

  def slots
    activities_by_hour = @progress.activities.index_by { |activity| activity.started_at.hour }

    (schedule.wake_up_hour...schedule.sleep_hour).map do |hour|
      Slot.new(hour: hour, activity: activities_by_hour[hour])
    end
  end
end
