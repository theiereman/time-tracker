require "test_helper"

class PublicStatisticsControllerTest < ActionDispatch::IntegrationTest
  test "renders statistics for a valid token without authentication" do
    link = UserProfileLink.create!(user: users(:one))

    get public_statistics_url(token: link.token)

    assert_response :success
  end

  test "returns 404 for an unknown token" do
    get public_statistics_url(token: "unknown")

    assert_response :not_found
  end
end
