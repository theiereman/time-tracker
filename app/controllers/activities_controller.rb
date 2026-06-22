class ActivitiesController < ApplicationController
  before_action :set_variables

  def index
    @feed = ProgressPresenter.new(User::Progress.for_the_day(Current.user, @schedule))
    @date = @activity.started_at.to_date
  end

  def create
    @activity.attributes = activity_params

    if @activity.save
      redirect_to activities_path(datetime: @activity.ended_at)
    else
      render turbo_stream: helpers.turbo_flash_toast(:alert, @activity.errors.full_messages.first)
    end
  end

  private

  def set_variables
    @schedule = User::Schedule.new(Current.user)
    datetime = get_most_accurate_activity_datetime
    @activity = Current.user.activities.find_by(started_at: datetime) || Current.user.activities.build(started_at: datetime)
    @categories = Current.user.activity_categories
  end

  def get_most_accurate_activity_datetime
    params.dig(:activity, :started_at) ||
    params[:datetime] ||
    Current.user.last_activity&.ended_at||
    @schedule.first_datetime_of_day
  end

  def activity_params
    params.expect(activity: [ :id, :started_at, :activity_category_id ])
  end
end
