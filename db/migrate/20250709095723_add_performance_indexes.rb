class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :noticed_notifications, [:recipient_type, :recipient_id, :read_at], 
              name: 'idx_notifications_recipient_read'
    add_index :noticed_notifications, [:recipient_type, :recipient_id, :created_at], 
              name: 'idx_notifications_recipient_created'
    add_index :noticed_notifications, [:event_id, :read_at], 
              name: 'idx_notifications_event_read'
    
    # Event performance indexes
    add_index :noticed_events, [:record_type, :record_id], 
              name: 'idx_events_record'
    add_index :noticed_events, :created_at, 
              name: 'idx_events_created_at'
    add_index :noticed_events, :type, 
              name: 'idx_events_type'
    
    # Post performance indexes
    add_index :posts, [:created_at, :id], 
              name: 'idx_posts_created_id'
    add_index :posts, :slug, unique: true, 
              name: 'idx_posts_slug_unique'
    add_index :posts, :user_id, 
              name: 'idx_posts_user'
    add_index :posts, :category_id, 
              name: 'idx_posts_category'
    
    # Comment performance indexes
    add_index :comments, [:post_id, :created_at], 
              name: 'idx_comments_post_created'
    add_index :comments, :user_id, 
              name: 'idx_comments_user'
    
    # Ahoy events for analytics (if you use them frequently)
    add_index :ahoy_events, [:name, :time], 
              name: 'idx_ahoy_events_name_time'
    add_index :ahoy_events, :properties, using: :gin, 
              name: 'idx_ahoy_events_properties'
  end
end
