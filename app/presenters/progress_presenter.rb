class ProgressPresenter
  delegate_missing_to :@user

  Slot = Data.define(:starts_at, :activity, :night) do
    def hour = starts_at.hour
    def filled? = activity.present?
    def label = filled? ? activity.category.label : I18n.t("activities.slot.empty")
  end

  def initialize(user)
    @user = user
  end

  def slots
    @user.slots_for(@user.date).map do |starts_at, activity|
      Slot.new(starts_at: starts_at, activity: activity, night: user.night?(starts_at.hour))
    end
  end

  private
end
