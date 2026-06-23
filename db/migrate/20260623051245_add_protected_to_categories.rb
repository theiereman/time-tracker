class AddProtectedToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :activity_categories, :protected, :boolean, default: false

    Activity::Category.where(label: "Sommeil").update_all(protected: true)
  end
end
