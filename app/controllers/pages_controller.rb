class PagesController < ApplicationController
   
  def home
    # Rails.logger.info "Render the homepage"
    return unless current_user
    return if current_user.payment_processor.nil?
    @portal_session = current_user.payment_processor.billing_portal
  end

  def about
  end
end
