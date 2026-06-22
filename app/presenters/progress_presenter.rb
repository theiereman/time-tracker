class ProgressPresenter
  delegate_missing_to :@user

  Slot = Data.define(:hour, :activity, :night) do
    def filled? = activity.present?
    def label = filled? ? activity.category.label : "Non renseigné"
  end

  def initialize(user)
    @user = user
  end

  def slots
    activities_by_hour = @user.activities.index_by { |activity| activity.started_at.hour }

    (0..23).map do |hour|
      Slot.new(hour: hour, activity: activities_by_hour[hour], night: !hour.between?(user.wake_up_hour, user.sleep_hour))
    end
  end

  private
end
