require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @activity = activities(:one)
  end

  test "should get index" do
    get activities_url
    assert_response :success
  end

  test "should create activity" do
    category = activity_categories(:one)
    assert_difference("Activity.count") do
      post activities_url, params: { activity: { started_at: "2026-06-10 09:00:00", activity_category_id: category.id } }
    end
    assert_redirected_to activities_url(datetime: Activity.last.ended_at)
  end

  test "a larger slot absorbs finer activities it overlaps" do
    user = users(:one)
    category = activity_categories(:one)

    user.update!(activity_duration_in_minutes: 30)
    post activities_url, params: { activity: { started_at: "2026-06-10 09:30:00", activity_category_id: category.id } }
    fine_activity = Activity.order(:created_at).last
    assert_equal Time.zone.local(2026, 6, 10, 9, 30), fine_activity.started_at

    user.update!(activity_duration_in_minutes: 60)
    post activities_url, params: { activity: { started_at: "2026-06-10 09:00:00", activity_category_id: category.id } }
    assert_redirected_to activities_url(datetime: Activity.last.ended_at)

    assert_not Activity.exists?(fine_activity.id)
    coarse_activity = Activity.order(:created_at).last
    assert_equal Time.zone.local(2026, 6, 10, 9, 0), coarse_activity.started_at
    assert_equal Time.zone.local(2026, 6, 10, 10, 0), coarse_activity.ended_at
  end
end
