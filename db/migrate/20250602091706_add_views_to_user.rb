class AddViewsToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :view, :integer
  end
end
