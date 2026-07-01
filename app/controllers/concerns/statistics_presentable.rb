module StatisticsPresentable
  extend ActiveSupport::Concern

  private
    def present_statistics_for(user)
      activities = user.activities
      presenter = ActivitiesPerCategoryPresenter.new(activities)
      @count_per_category = presenter.present
      @top_categories = presenter.top_table
      @hours_per_category_over_time = HoursPerCategoryPresenter.present(activities)
    end
end
