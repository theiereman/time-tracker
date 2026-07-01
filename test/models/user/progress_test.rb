require "test_helper"

class User::ProgressTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @category = activity_categories(:one)
    @date = Date.new(2026, 6, 10)
  end

  def progress
    User::Progress.for_the_day(@user, @date)
  end

  test "a finer activity fills its coarse slot and counts once" do
    @user.update!(activity_duration_in_minutes: 30)
    @user.activities.create!(started_at: Time.zone.local(2026, 6, 10, 10, 0), category: @category)

    @user.update!(activity_duration_in_minutes: 60)

    assert_equal 1, progress.filled_slots_on(@date)
    assert_equal 23, progress.remaining_activities_count(date: @date)
  end

  test "a coarse activity fills every finer slot it spans" do
    @user.update!(activity_duration_in_minutes: 60)
    @user.activities.create!(started_at: Time.zone.local(2026, 6, 10, 10, 0), category: @category)

    @user.update!(activity_duration_in_minutes: 15)

    assert_equal 4, progress.filled_slots_on(@date)
  end

  test "a day is done once every slot on the current grid is filled" do
    @user.update!(activity_duration_in_minutes: 60)
    24.times { |h| @user.activities.create!(started_at: Time.zone.local(2026, 6, 10, h, 0), category: @category) }

    assert progress.all_activities_done?(date: @date)
    assert_equal 0, progress.remaining_activities_count(date: @date)
  end
end
