class Activity::Category < ApplicationRecord
  belongs_to :user
  has_many :activities, foreign_key: "activity_category_id", dependent: :restrict_with_error

  scope :sleep, -> { where(protected: true).first }

  before_destroy -> { throw(:abort) if protected? }
  validate :label_immutable_when_protected, on: :update

  def self.create_default_categories_for(user)
    default_categories = [
      { label: I18n.t("activity.category.defaults.reading"), color: "#8ff0a4" },
      { label: I18n.t("activity.category.defaults.cooking"), color: "#f66151" },
      { label: I18n.t("activity.category.defaults.leisure"), color: "#f6d32d" },
      { label: I18n.t("activity.category.defaults.outings"), color: "#99c1f1" },
      { label: I18n.t("activity.category.defaults.work"), color: "#dc8add" },
      { label: I18n.t("activity.category.defaults.sleep"), protected: true, color: "#6b7280" }
    ]

    default_categories.each do |category_attrs|
      user.activity_categories.create!(category_attrs)
    end
  end

  private

  def label_immutable_when_protected
    errors.add(:base, :protected) if protected? && (label_changed? || color_changed?)
  end
end
