# To deliver this notification:
#
# CommentNotifier.with(post: @post, message: "New comment").deliver_later(@user)


class CommentNotifier < ApplicationNotifier
  # Add your delivery methods
  #
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   config.method = "new_post"
  # end
  #
  # bulk_deliver_by :slack do |config|
  #   config.url = -> { Rails.application.credentials.slack_webhook_url }
  # end
  #
  # deliver_by :custom do |config|
  #   config.class = "MyDeliveryMethod"
  # end

  # Add required params
  #
  # required_param :message
  def message
    @post = params[:post]
    @commenter = params[:commenter]

    # Debug logging
    # Rails.logger.info "DEBUG: Post: #{@post.inspect}"
    # Rails.logger.info "DEBUG: Commenter: #{@commenter.inspect}"
    # Rails.logger.info "DEBUG: All params: #{params.inspect}"

    # Handle case where params are available (new notifications)
    if @post && @commenter
      return "#{@commenter.full_name} replied to #{@post.title.truncate(14)}"
    end

    # Handle case where params are not available (old notifications)
    # You might need to reconstruct the message from the notification record itself
    "Someone replied to a post"
  end

  # That allows us to do our url construction
  def url
    # Use params directly and add nil check
    return root_path unless params[:post]

    post_path(params[:post].id)
  end
end
