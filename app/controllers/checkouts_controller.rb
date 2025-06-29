class CheckoutsController < ApplicationController
  before_action :authenticate_user!


  def show
    current_user.set_payment_processor :stripe
    current_user.payment_processor.customer_name
    @checkout_session = current_user
      .payment_processor
      .checkout(
        mode: params[:payment_mode],
        line_items: params[:line_items],
        success_url: checkout_success_url + "?stripe_checkout_session_id={CHECKOUT_SESSION_ID}"
      )
  end
  def success
      @session = Stripe::Checkout::Session.retrieve(params[:stripe_checkout_session_id])
      @line_item = Stripe::Checkout::Session.list_line_items(params[:stripe_checkout_session_id])
      current_user.payment_processor.sync_subscriptions if current_user.payment_processor
  end
end