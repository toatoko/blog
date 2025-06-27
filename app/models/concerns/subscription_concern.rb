module SubscriptionConcern
  extend ActiveSupport::Concern
  included do
    def check_subscription_status
      subscription = payment_processor&.subscriptions&.active&.first
      Rails.logger.debug "Subscription found: #{subscription.inspect}"
      return if subscription.nil?

        update(
          subscription_status: subscription.status,
          subscription_end_date: Time.at(subscription.current_period_end),
          subscription_start_date: Time.at(subscription.current_period_start)
        )
    end

    def active_subscription
      payment_processor&.subscribed?
    end
  end
end
