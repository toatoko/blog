# config/initializers/action_text_ransack.rb
Rails.application.config.to_prepare do
  ActionText::RichText.class_eval do
    def self.ransackable_attributes(auth_object = nil)
      [ "body", "created_at", "id", "name", "record_id", "record_type", "updated_at" ]
    end
  end
end
