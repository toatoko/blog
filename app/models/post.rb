class Post < ApplicationRecord
  validates :title, presence: true, length: { minimum: 5, maximum: 50 }
  validates :body, presence: true, length: { minimum: 10, maximum: 5000 }
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :notifications, through: :user, dependent: :destroy
  has_many :notification_mentions, through: :user, dependent: :destroy
  has_noticed_notifications model_name: "Noticed::Notification"
  def self.ransackable_attributes(auth_object = nil)
    [ "title", "body", "user_id", "created_at", "updated_at", "id", "views" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "user" ]
  end
end
