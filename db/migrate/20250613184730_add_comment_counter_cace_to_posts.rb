class AddCommentCounterCaceToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :comments_count, :integer
  end
end
