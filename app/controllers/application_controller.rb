class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_notifications, if: :current_user
  before_action :set_query
  before_action :set_categories
  helper_method :notification_redirect_path
  def set_query
    @query = Post.ransack(params[:q])
  end

  private
  
  def set_categories
    @categories = Category.all.order(:name)
  end
  # In ApplicationController
  def set_notifications
    return unless current_user
    
    # Use efficient queries with proper limits
    @unread = current_user.unread_notifications
                          .includes(:event)
                          .order(created_at: :desc)
                          .limit(5)
    
    @read = current_user.read_notifications
                        .includes(:event)
                        .order(created_at: :desc)
                        .limit(4)
  end

  def notification_redirect_path(notification)
    if notification.event&.respond_to?(:url)
      notification.event.url
    elsif notification.event&.record.is_a?(Post)
      post_path(notification.event.record)
    elsif notification.event&.record.is_a?(Comment)
      post_path(notification.event.record.post)
    else
      root_path
    end
  rescue => e
    Rails.logger.error "Error generating notification redirect path: #{e.message}"
    root_path
  end
end
