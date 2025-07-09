# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications
                                .includes(:event)
                                .order(created_at: :desc)
                                .limit(50) # Limit to prevent performance issues
    
    # Mark all unread notifications as read when user visits this page
    current_user.unread_notifications.update_all(read_at: Time.current)
  end

  def show
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read! if @notification.unread?
    
    # Redirect to the notification's target URL
    redirect_to notification_redirect_path(@notification)
  end

  def update
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!
    
    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_back(fallback_location: notifications_path) }
    end
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy
    
    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to notifications_path, notice: 'Notification deleted' }
    end
  end

  private

  def notification_redirect_path(notification)
    # Try to get the URL from the notification event
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