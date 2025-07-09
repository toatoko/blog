class AddNotificationsCounterCache < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :notifications_count, :integer, default: 0, null: false
    add_index :users, :notifications_count
    
    # Don't add counter cache to posts - notifications belong to users, not posts
    
    # Manually update the counter cache values
    reversible do |dir|
      dir.up do
        # Update counter cache for existing data
        execute <<-SQL
          UPDATE users 
          SET notifications_count = (
            SELECT COUNT(*) 
            FROM noticed_notifications 
            WHERE noticed_notifications.recipient_type = 'User' 
            AND noticed_notifications.recipient_id = users.id
          )
        SQL
      end
    end
  end
end