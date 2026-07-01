class ActivitiesPerCategoryPresenter
  def self.present(activities)
    new(activities).present
  end

  def initialize(activities)
    @activities = activities
  end

  def present
    sorted.map { |(label, color), hours| { name: label, data: { label => hours }, color: color } }
  end

  def top_table(limit: 10)
    total = sorted.sum { |_, hours| hours }
    sorted.first(limit).map do |(label, color), hours|
      { label: label, color: color, count: hours, percentage: total > 0 ? (hours.to_f / total * 100).round(1) : 0 }
    end
  end

  private

  def sorted
    @sorted ||= hours_by_label_and_color.sort_by { |_, hours| -hours }
  end

  def hours_by_label_and_color
    @cache ||= @activities
      .includes(:category)
      .group_by { |a| [ a.category.label, a.category.color ] }
      .transform_values { |acts| (acts.sum { |a| a.ended_at - a.started_at } / 3600.0).round(2) }
  end
end
