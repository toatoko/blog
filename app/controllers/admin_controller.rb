class AdminController < ApplicationController
  def index
  end

  def posts
    @posts = Post.all.includes(:user).order(created_at: :asc, id: :asc)
  end

  def comments
  end

  def users
    @users = User.all
  end
  def categories
    @categories = Category.all
  end
  def show_post
    @post = Post.includes(:user, comments: [:user, :rich_text_body]).friendly.find(params[:id])
  end
end
