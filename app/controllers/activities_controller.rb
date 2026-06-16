class ActivitiesController < ApplicationController
  before_action :set_time
  before_action :set_categories, only: :index

  def index
  end

  def create
    @activity = Activity.new(activity_params)
    @activity.started_at = @current_datetime

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

  def set_time
    @current_datetime = Current.user.next_activity_start_datetime
    @day = @current_datetime.to_date
  end

  def activity_params
    params.expect(activity: [ :activity_category_id ])
  end
end
