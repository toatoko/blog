class Category < ApplicationRecord
  has_many :posts, dependent: :destroy
  validates :name,presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 50}
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "name", "posts_count", "updated_at"]
  end
  def self.scheduled_category
    Category.create(name: "Scheduled at #{Time.now}")
  end
end
