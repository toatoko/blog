class UsersController < ApplicationController
  before_action :set_user
  def profile
    @user.update(views: @user.views + 1)
    @posts = @user.posts.order(created_at: :desc)
    @total_views = 0
    @posts.each do |post|
      @total_views += post.views
    end
  end
  def set_user
    @user = User.find(params[:id])
  end
end
