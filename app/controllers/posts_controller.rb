class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: %i[show index]
  # GET /posts or /posts.json
  def index
    @posts = Post.all.includes([:user, :rich_text_body, :images_attachments, :category])
                .order(created_at: :asc, id: :asc)
    
    if current_user
      # More efficient notification loading
      @notifications = current_user.notifications
                                  .joins(:event)
                                  .includes(:event)
                                  .where(read_at: nil)
                                  .order(created_at: :desc)
                                  .limit(10)
      
      # Get post IDs from events efficiently
      notification_post_ids = Noticed::Event.joins(:notifications)
                                            .where(
                                              noticed_notifications: { 
                                                recipient: current_user, 
                                                read_at: nil 
                                              },
                                              record_type: 'Post'
                                            )
                                            .pluck(:record_id)
                                            .uniq
      
      @notification_posts = Post.includes(:user, :slugs)
                                .where(id: notification_post_ids)
                                .index_by(&:id)
    end
  end

  # GET /posts/1 or /posts/1.json
  def show
    @post.increment!(:views) 
    @comments = @post.comments.includes([:user, :rich_text_body])
                              .order(created_at: :desc)
    ahoy.track 'Viewed Post', post_id: @post.id
    mark_notifications_as_read
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)
    @post.user = current_user

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      # Handle images separately to preserve existing ones
      if params[:post][:images].present?
        # Remove any blank entries and attach new images
        new_images = params[:post][:images].reject(&:blank?)
        @post.images.attach(new_images) if new_images.any?
      end
      
      # Update other attributes (excluding images since we handled them above)
      other_params = post_params.except(:images)
      
      # Only update if there are other parameters to update
      success = other_params.empty? || @post.update(other_params)
      
      if success
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.comments.destroy_all
    @post.delete

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.friendly.find(params[:id])
    redirect_to @post, status: :moved_permanently if params[:id] != @post.slug
  end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :category_id, images: [])
    end

  def mark_notifications_as_read
    return unless current_user

    # Mark post notifications as read
    post_notifications = current_user.notifications
                                    .joins(:event)
                                    .where(noticed_events: { 
                                      record_type: 'Post', 
                                      record_id: @post.id 
                                    })
                                    .where(read_at: nil)
    
    # Mark comment notifications as read for this post
    comment_notifications = current_user.notifications
                                      .joins(:event)
                                      .where(noticed_events: { 
                                        record_type: 'Comment', 
                                        record_id: @post.comments.pluck(:id) 
                                      })
                                      .where(read_at: nil)
    
    # Update all at once
    all_notifications = post_notifications.or(comment_notifications)
    all_notifications.update_all(read_at: Time.zone.now)
  end
end
