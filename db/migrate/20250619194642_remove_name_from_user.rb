class RemoveNameFromUser < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :name, :string
  end
end
