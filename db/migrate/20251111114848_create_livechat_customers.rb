class CreateLivechatCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :livechat_customers, id: :string do |t|
      # Foreign key to users (string PK with UUID stored as text)
      t.string  :user_id,     null: false

      # Token fields (required by LiveChat CIP response)
      t.string  :access_token, null: false
      t.string  :client_id
      t.string  :entity_id,    null: false
      t.integer :expires_in
      t.string  :token_type

      t.timestamps
    end

    add_index :livechat_customers, :user_id
    add_index :livechat_customers, :entity_id, unique: true 
    add_foreign_key :livechat_customers, :users, column: :user_id
  end
end
