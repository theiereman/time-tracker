class Activity::Category < ApplicationRecord
  belongs_to :user
  has_many :activities, foreign_key: "activity_category_id", dependent: :restrict_with_error

  scope :sleep, -> { where(label: "Sommeil").first }

  before_destroy -> { throw(:abort) if protected? }
  validate :label_immutable_when_protected, on: :update

  def self.create_default_categories_for(user)
    default_categories = [
      { label: "Lecture", color: "#8ff0a4" },
      { label: "Cuisine", color: "#f66151" },
      { label: "Loisirs", color: "#f6d32d" },
      { label: "Sorties", color: "#99c1f1" },
      { label: "Travail", color: "#dc8add" },
      { label: "Sommeil", protected: true, color: "#6b7280"  }
    ]

    default_categories.each do |category_attrs|
      user.activity_categories.create!(category_attrs)
    end
  end

  private

  def label_immutable_when_protected
    errors.add(:base, "Cette catégorie est protégée et ne peut pas être modifiée") if protected? && (label_changed? || color_changed?)
  end
end
