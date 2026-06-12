require "test_helper"

class MagicLinkAuthenticationTest < ActionDispatch::IntegrationTest
  test "full sign-in flow with a magic link code" do
    # Unauthenticated visit redirects to the sign-in page.
    get root_path
    assert_redirected_to new_session_path

    # Request a code for a new email address: creates the user and a magic link.
    assert_difference [ "User.count", "MagicLink.count" ], 1 do
      post session_path, params: { email_address: "alice@example.com" }
    end
    assert_redirected_to new_session_magic_link_path

    user = User.find_by!(email_address: "alice@example.com")
    code = user.magic_links.last.code

    # Submitting the correct code starts a session and lands on the app.
    post session_magic_link_path, params: { code: code }
    assert_redirected_to root_path
    assert_equal 0, MagicLink.count, "magic link should be consumed (single-use)"

    follow_redirect!
    assert_response :success
    assert_select "strong", text: "alice@example.com"

    # Signing out clears the session.
    delete session_path
    assert_redirected_to new_session_path

    get root_path
    assert_redirected_to new_session_path
  end

  test "an invalid code is rejected" do
    post session_path, params: { email_address: "bob@example.com" }
    post session_magic_link_path, params: { code: "BADCOD" }
    assert_redirected_to new_session_magic_link_path
    assert_nil cookies[:session_id].presence
  end

  test "code page requires a pending email address" do
    get new_session_magic_link_path
    assert_redirected_to new_session_path
  end
end
