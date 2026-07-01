require "test_helper"

class ActivityTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @category = activity_categories(:one)
  end

  def build_activity(started_at)
    @user.activities.build(started_at: started_at, category: @category)
  end

  test "defaults to a one-hour slot snapped to the hour" do
    @user.update!(activity_duration_in_minutes: 60)
    activity = build_activity(Time.zone.local(2026, 6, 20, 10, 37))
    activity.save!

    assert_equal Time.zone.local(2026, 6, 20, 10, 0), activity.started_at
    assert_equal Time.zone.local(2026, 6, 20, 11, 0), activity.ended_at
  end

  test "honours a 15-minute duration and snaps to the slot grid" do
    @user.update!(activity_duration_in_minutes: 15)
    activity = build_activity(Time.zone.local(2026, 6, 20, 10, 37))
    activity.save!

    assert_equal Time.zone.local(2026, 6, 20, 10, 30), activity.started_at
    assert_equal Time.zone.local(2026, 6, 20, 10, 45), activity.ended_at
  end

  test "rejects an activity overlapping an existing one of a different duration" do
    @user.update!(activity_duration_in_minutes: 60)
    build_activity(Time.zone.local(2026, 6, 20, 10, 0)).save!

    @user.update!(activity_duration_in_minutes: 15)
    overlapping = build_activity(Time.zone.local(2026, 6, 20, 10, 15))

    assert_not overlapping.valid?
    assert overlapping.errors.of_kind?(:base, :already_exists)
  end

  test "allows back-to-back slots" do
    @user.update!(activity_duration_in_minutes: 15)
    build_activity(Time.zone.local(2026, 6, 20, 10, 0)).save!

    assert build_activity(Time.zone.local(2026, 6, 20, 10, 15)).valid?
  end

  test "keeps an existing slot's duration when the setting later changes" do
    @user.update!(activity_duration_in_minutes: 60)
    activity = build_activity(Time.zone.local(2026, 6, 20, 10, 0))
    activity.save!

    @user.update!(activity_duration_in_minutes: 15)
    activity.category = @category
    activity.save!

    assert_equal Time.zone.local(2026, 6, 20, 11, 0), activity.reload.ended_at
  end
end
