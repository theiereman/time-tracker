class ActivitiesController < ApplicationController
  before_action :set_variables, except: [ :mark_night_as_sleep ]

  def index
    @date = @activity.started_at.to_date
    @feed = ProgressPresenter.new(User::Progress.for_the_day(Current.user, @date))
  end

  def create
    @activity.attributes = activity_params

    if @activity.save
      redirect_to activities_path(datetime: @activity.ended_at)
    else
      render turbo_stream: helpers.turbo_flash_toast(:alert, @activity.errors.full_messages.first)
    end
  end

  def mark_night_as_sleep
    @date = params[:date].to_date
    @error = false
    Current.user.sleep_hours.each do |h|
      datetime = DateTime.new(@date.year, @date.month, @date.day, h)
      activity = Current.user.activities.find_by(started_at: datetime) || Current.user.activities.build(started_at: datetime)
      activity.category = Current.user.activity_categories.sleep
      if activity.save
          @error = true
      end
    end
  end

  private

  def set_variables
    datetime = get_most_accurate_activity_datetime
    @activity = Current.user.activities.find_by(started_at: datetime) || Current.user.activities.build(started_at: datetime)
    @categories = Current.user.activity_categories
  end

  def get_most_accurate_activity_datetime
    last_activity = Current.user.last_activity
    last_activity_datetime = last_activity&.ended_at if last_activity&.ended_at&.to_date&.<=(Date.current)
    date = params.dig(:activity, :started_at) ||
    params[:datetime] ||
    !params[:date].nil? && Current.user.wake_up_datetime(date: params[:date].to_date) ||
    last_activity_datetime||
    Current.user.wake_up_datetime(date: Date.current)

    redirect_back fallback_location: root_path and return if date.to_date > Date.current

    date
  end

  def activity_params
    params.expect(activity: [ :id, :started_at, :activity_category_id ])
  end
end
