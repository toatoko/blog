class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  def create
    @comment = @post.comments.build(comment_params)
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
    ActiveRecord::Base.transaction do
      @comment.rich_text_body&.destroy
      Noticed::Notification.joins(:event)
                          .where(noticed_events: { record_type: "Comment", record_id: @comment.id })
                          .destroy_all
      Noticed::Event.where(record_type: "Comment", record_id: @comment.id).destroy_all
      @comment.destroy
    end
    
    redirect_to post_path(@post)
  end

  private
  def set_post
    @post = Post.friendly.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
