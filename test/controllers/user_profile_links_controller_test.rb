require "test_helper"

class UserProfileLinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in(@user)
  end

  test "create finds or creates a link for the current user" do
    post user_profile_link_url

    assert_response :success
    assert @user.reload.user_profile_link.present?
  end

  test "update regenerates the link" do
    link = UserProfileLink.find_or_create_for(@user)

    patch user_profile_link_url

    assert_response :success
    assert_not_equal link.token, @user.reload.user_profile_link.token
  end
end
