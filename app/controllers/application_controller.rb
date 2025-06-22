class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_notifications, if: :current_user
  before_action :set_query
  before_action :set_categories
  def set_query
    @query = Post.ransack(params[:q])
  end

  private
  def set_categories
    @categories = Category.all.order(:name)
  end
  def set_notifications
    notifications = Noticed::Notification.includes([:event ]).where(recipient: current_user).newest_first.limit(9)
    @unread = notifications.unread
    @read = notifications.read
  end
end
