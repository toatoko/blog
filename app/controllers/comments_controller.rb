class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  def create
    @comment = @post.comments.create(comment_params)
    @comment.user = current_user
    if @comment.save
      flash[:notice] = "Comment has been created"
      redirect_to post_path(@post)
    else
      flash[:alert] = "Comment has not been created"
      redirect_to post_path(@post)
    end
  end

  def update
    @comment = @post.comments.find(params[:id])

    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to post_url(@post), notice: "Comment has been updated" }
      else
        format.html { redirect_to post_url(@post), alert: "Comment was not updated" }
      end
    end
  end
  def destroy
    @comment = @post.comments.find(params[:id])
    ActionText::RichText.where(record_type: "Comment", record_id: @comment.id).destroy_all
    Noticed::Event.where(record_type: "Comment", record_id: @comment.id).destroy_all
    Noticed::Notification.where(recipient_type: "User", recipient_id: current_user.id, event_id: @comment.id).destroy_all
    @comment.destroy
    redirect_to post_path(@post)
  end

  private
  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
