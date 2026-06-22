class ActivitiesProgressPresenter
  delegate_missing_to :@activities_progress

  Slot = Data.define(:hour, :activity) do
    def filled? = activity.present?
    def label = filled? ? activity.category.label : "Non renseigné"
  end

  def initialize(activities_progress)
    @activities_progress = activities_progress
  end

  def slots
    activities_by_hour = @activities_progress.activities.index_by { |activity| activity.started_at.hour }

    (schedule.wake_up_hour...schedule.sleep_hour).map do |hour|
      Slot.new(hour: hour, activity: activities_by_hour[hour])
    end
  end
end
