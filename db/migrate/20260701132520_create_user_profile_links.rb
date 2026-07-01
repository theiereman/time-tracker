class CreateUserProfileLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :user_profile_links do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :token, null: false

      t.timestamps
    end
    add_index :user_profile_links, :token, unique: true
  end
end
