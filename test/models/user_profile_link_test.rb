require "test_helper"

class UserProfileLinkTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "generates a unique token on create" do
    link = UserProfileLink.create!(user: @user)

    assert link.token.present?
  end

  test "find_or_create_for reuses the existing link for a user" do
    first = UserProfileLink.find_or_create_for(@user)
    second = UserProfileLink.find_or_create_for(@user)

    assert_equal first.id, second.id
    assert_equal first.token, second.token
  end

  test "regenerate! replaces the token" do
    link = UserProfileLink.find_or_create_for(@user)
    original_token = link.token

    link.regenerate!

    assert_not_equal original_token, link.token
  end

  test "a user can only have one link" do
    UserProfileLink.create!(user: @user)
    duplicate = UserProfileLink.new(user: @user)

    assert_not duplicate.valid?
  end

  test "gives up after repeated token collisions instead of looping forever" do
    existing = UserProfileLink.create!(user: @user)
    original_urlsafe_base64 = SecureRandom.method(:urlsafe_base64)
    SecureRandom.define_singleton_method(:urlsafe_base64) { |*| existing.token }

    assert_raises UserProfileLink::TokenGenerationError do
      UserProfileLink.generate_unique_token
    end
  ensure
    SecureRandom.define_singleton_method(:urlsafe_base64, original_urlsafe_base64)
  end
end
