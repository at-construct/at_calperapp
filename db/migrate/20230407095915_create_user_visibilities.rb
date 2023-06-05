class CreateUserVisibilities < ActiveRecord::Migration[6.1]
  def change
    create_table :user_visibilities do |t|
      t.integer :target_user_id, null: false
      t.integer :user_id, null: false
      t.boolean :visibility, null: false, default: true

      t.timestamps
    end

    add_index :user_visibilities, [:user_id, :target_user_id], unique: true
  end
end
