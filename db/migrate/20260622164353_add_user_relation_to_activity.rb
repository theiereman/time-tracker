class AddUserRelationToActivity < ActiveRecord::Migration[8.0]
  def change
    add_reference :activities, :user, null: false, foreign_key: true

    Activity.includes(:category).find_each do |a|
      a.update!(user: a.category.user)
    end
  end
end
