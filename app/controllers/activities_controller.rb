class ActivitiesController < ApplicationController
  before_action :set_schedule
  before_action :set_categories, only: :index

  def index
    @activity = Activity.find_by(id: params[:activity_id])
    set_feed
  end


  def create
    @activity = Current.user.activities.find_by(id: activity_params[:id]) || Activity.new
    @activity.attributes = activity_params

    if @activity.save
      redirect_to activities_path
    else
      render turbo_stream: helpers.turbo_flash_toast(:alert, @activity.errors.full_messages.first)
    end
  end

  private

  def set_categories
    @categories = Current.user.activity_categories
  end

  def set_schedule
    @schedule = User::Schedule.new(Current.user)
  end

  def set_feed
    @feed = ActivitiesProgressPresenter.new(User::ActivitiesProgress.for_the_day(Current.user, @schedule))
    @activity_slot = params[:datetime]&.to_datetime || User::ActivitySlot.new(Current.user.activities, @schedule).get_next
    @date = @activity_slot.to_date
  end

  def activity_params
    params.expect(activity: [ :id, :started_at, :activity_category_id ])
  end
end
