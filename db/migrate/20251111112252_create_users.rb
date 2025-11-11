class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :string do |t|
      t.string :username, null: false
      t.string :email,    null: false
      t.timestamps
    end
  end
end
