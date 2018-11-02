class AddLoguxFieldsUpdatedAtToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :logux_fields_updated_at, :jsonb, null: false, default: {}
  end
end
