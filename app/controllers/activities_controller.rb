class ActivitiesController < ApplicationController
  before_action :set_variables, except: [ :mark_night_as_sleep, :destroy ]
  before_action :set_activity, only: [ :destroy ]

  def index
    @date = @activity.started_at.to_date
    @feed = ProgressPresenter.new(User::Progress.for_the_day(Current.user, @date))
  end

  def create
    @activity.attributes = activity_params
    @activity.started_at = Current.user.snap_to_activity_slot(@activity.started_at)
    @activity.ended_at = @activity.started_at + Current.user.activity_duration_in_minutes.minutes

    absorb_overlapping_activities

    if @activity.save
      redirect_to activities_path(datetime: @activity.ended_at)
    else
      render turbo_stream: helpers.turbo_flash_toast(:alert, @activity.errors.full_messages.first)
    end
  end

  def destroy
    @activity.destroy
    redirect_to activities_path(datetime: @activity.started_at)
  end

  def mark_night_as_sleep
    @date = params[:date].to_date
    failed = nil

    sleep_slot_start_times.each do |datetime|
      activity = Current.user.activities.find_by(started_at: datetime) || Current.user.activities.build(started_at: datetime)
      activity.category = Current.user.activity_categories.sleep
      failed ||= activity unless activity.save
    end

    if failed
      render turbo_stream: helpers.turbo_flash_toast(:alert, failed.errors.full_messages.first)
    else
      redirect_to activities_path(datetime: Current.user.wake_up_datetime(date: @date))
    end
  end

  private

  def absorb_overlapping_activities
    Current.user.activities
      .overlapping(@activity.started_at, @activity.ended_at)
      .where.not(id: @activity.id)
      .destroy_all
  end

  def sleep_slot_start_times
    duration = Current.user.activity_duration_in_minutes
    Current.user.sleep_hours.flat_map do |h|
      hour_start = Time.zone.local(@date.year, @date.month, @date.day, h)
      (0...60).step(duration).map { |m| hour_start + m.minutes }
    end
  end

  def set_activity
    @activity = Current.user.activities.find(params[:id])
  end

  def set_variables
    datetime = Current.user.snap_to_activity_slot(get_most_accurate_activity_datetime)
    @activity = Current.user.activities.find_by(started_at: datetime) ||
                Current.user.activities.build(started_at: datetime, ended_at: datetime + Current.user.activity_duration_in_minutes.minutes)
    @categories = Current.user.activity_categories
  end

  def get_most_accurate_activity_datetime
    datetime = params.dig(:activity, :started_at) ||
                params[:datetime] ||
                params[:date].present? && params[:date].to_date.beginning_of_day ||
                Current.user.last_activity(Date.current)&.ended_at ||
                Time.current

    datetime = Time.zone.parse(datetime.to_s) if datetime.is_a?(String)
    return Time.current if datetime.to_date > Date.current
    datetime
  end

  def activity_params
    params.expect(activity: [ :id, :started_at, :activity_category_id ])
  end
end
