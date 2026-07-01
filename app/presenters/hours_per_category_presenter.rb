class HoursPerCategoryPresenter
  def self.present(activities)
    new(activities).present
  end

  def initialize(activities)
    @activities = activities
  end

  def present
    hours_by_category_and_date.map do |category, data|
      {
        name: category.label,
        data: all_dates.index_with { |d| hours_for(data[d]) },
        color: category.color
      }
    end
  end

  private

  def hours_for(acts)
    return 0 if acts.nil?

    (acts.sum { |a| a.ended_at - a.started_at } / 3600.0).round(2)
  end

  def all_dates
    hours_by_category_and_date.values.flat_map(&:keys).uniq.sort
  end

  def hours_by_category_and_date
    @cache ||= @activities
      .includes(:category)
      .group_by { |a| [ a.category, a.started_at.to_date ] }
      .each_with_object(Hash.new { |h, k| h[k] = {} }) do |(key, acts), hash|
        category, date = key
        hash[category][date] = acts
      end
  end
end
