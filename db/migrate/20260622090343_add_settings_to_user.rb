class AddSettingsToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :settings, :json
  end
end
