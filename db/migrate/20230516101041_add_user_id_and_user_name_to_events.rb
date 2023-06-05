class AddUserIdAndUserNameToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :user_name, :string
  end
end
