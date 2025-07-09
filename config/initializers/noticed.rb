Rails.application.config.to_prepare do
  Noticed::Notification.class_eval do
    belongs_to :recipient, polymorphic: true, counter_cache: true
  end
end