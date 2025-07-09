class Post < ApplicationRecord
  extend FriendlyId
  validates :title, presence: true, length: { minimum: 5, maximum: 50 }
  validates :body, presence: true
  belongs_to :user
  belongs_to :category, counter_cache: true
  before_validation :assign_default_category
  has_many :comments, dependent: :destroy
  has_rich_text :body
  # Single image upload
  # has_one_attached :image
  # multiple images upload
  has_many_attached :images
  
  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :notifications, through: :noticed_events, dependent: :destroy, class_name: "Noticed::Notification"
  
  has_noticed_notifications model_name: "Noticed::Event"

  def self.ransackable_attributes(auth_object = nil)
    [ "rich_text_body", "title", "user_id", "created_at", "updated_at", "id", "views" ]
  end
  
  def self.ransackable_associations(auth_object = nil)
    [ "user", "rich_text_body", "category" ]
  end
  
  friendly_id :title, use: %i[slugged history finders]

  def should_generate_new_friendly_id?
    title_changed? || slug.blank?
  end

  def views_by_day
    Ahoy::Event.where(name: 'Viewed Post')
              .where("properties ->> 'post_id' = ?", id.to_s)
              .group_by_day(:time, range: 1.month.ago..Time.now)
              .count
  end

  def self.total_views_by_day
    Ahoy::Event.where(name: 'Viewed Post')
              .group_by_day(:time, range: 1.month.ago..Time.now)
              .count
  end



  private
  def assign_default_category
    self.category ||= Category.find_by(name: "Uncategorized")
  end
  
end
