class PopulatePostCommentsCount < ActiveRecord::Migration[8.0]
  def change
    Post.all.each do |post|
      Post.reset_counters(post.id, :comments)
    end
  end
end
