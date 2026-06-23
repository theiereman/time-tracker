class Activity::Category < ApplicationRecord
  belongs_to :user
  has_many :activities, foreign_key: "activity_category_id", dependent: :restrict_with_error

  scope :sleep, -> { where(label: "Sommeil").first }

  before_destroy -> { throw(:abort) if protected? }
  validate :label_immutable_when_protected, on: :update

  def self.create_default_categories_for(user)
    default_categories = [
      { label: "Lecture" },
      { label: "Cuisine" },
      { label: "Loisirs" },
      { label: "Sorties" },
      { label: "Travail" },
      { label: "Sommeil" }
    ]

    default_categories.each do |category_attrs|
      user.activity_categories.create!(category_attrs)
    end
  end

  private

  def label_immutable_when_protected
    errors.add(:base, "Cette catégorie est protégée et ne peut pas être modifiée") if protected? && label_changed?
  end
end
