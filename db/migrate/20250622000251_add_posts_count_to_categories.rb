class AddPostsCountToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :posts_count, :integer
  end
end
