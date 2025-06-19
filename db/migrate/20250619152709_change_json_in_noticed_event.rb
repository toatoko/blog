class ChangeJsonInNoticedEvent < ActiveRecord::Migration[8.0]
  def change
    change_column :noticed_events, :params, :jsonb, using: 'params::jsonb'
  end
end
