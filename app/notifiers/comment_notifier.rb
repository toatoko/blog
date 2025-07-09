# To deliver this notification:
#
# CommentNotifier.with(post: @post, message: "New comment").deliver_later(@user)


class CommentNotifier < ApplicationNotifier
  required_param :post
  required_param :commenter
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
    begin
      if @post && @commenter
        post_title = @post.title.present? ? @post.title.truncate(14) : "a post"
        commenter_name = @commenter.full_name.present? ? @commenter.full_name : "Someone"
        return "#{commenter_name} replied to #{post_title}"
      end
    rescue => e
      Rails.logger.error "CommentNotifier message error: #{e.message}"
      Rails.logger.error "Params: #{params.inspect}"
    end

    # Handle case where params are not available (old notifications)
    # You might need to reconstruct the message from the notification record itself
    "Someone replied to a post"
  end

  # That allows us to do our url construction
  def url
    return root_path unless params[:post]

    begin
      # Use friendly URLs if available, otherwise fall back to ID
      if params[:post].respond_to?(:slug) && params[:post].slug.present?
        post_path(params[:post].slug)
      else
        post_path(params[:post].id)
      end
    rescue => e
      Rails.logger.error "CommentNotifier URL generation error: #{e.message}"
      root_path
    end
  end
end
