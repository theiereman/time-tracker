class ActivitiesController < ApplicationController
  before_action :set_variables
  before_action :set_categories, only: :index

  def index
    @feed = DayProgressPresenter.new(User::DayProgress.new(Current.user, @schedule))
  end


  def create
    @activity = Activity.new(activity_params)
    @activity.started_at = @next_activity_slot

    if @activity.save
      redirect_to activities_path
    else
      redirect_to activities_path, alert: @activity.errors.full_messages.first
    end
  end

  private

  def set_categories
    @categories = Current.user.activity_categories
  end

  def set_variables
    @schedule = User::Schedule.new(Current.user)
    @next_activity_slot = User::ActivitySlot.new(Current.user.activities, @schedule).get_next
  end

  def activity_params
    params.expect(activity: [ :activity_category_id ])
  end
end
