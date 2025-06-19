class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user
  has_rich_text :body
  after_create_commit :notify_recipient
  before_destroy :cleanup_notifications
  has_noticed_notifications model_name: "Noticed::Event"
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"

  private

  def notify_recipient
    return if post.nil? || user.nil? || post.user == user

    CommentNotifier.with(post: post, commenter: user, message: "New comment").deliver_later(post.user)
  end 
# CommentNotifier.with(post: @post, commenter: @comment.user, message: "New comment").deliver_later(@post.user)
  def cleanup_notifications
      post.notifications.where(id: post.id).destroy_all
  end
end
