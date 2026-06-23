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
end
