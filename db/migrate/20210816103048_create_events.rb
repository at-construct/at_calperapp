class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.string :name, limit: 100, null: false  # オプションを追加
      t.datetime :start, null: false           # オプションを追加
      t.datetime :end, null: false             # オプションを追加
      t.boolean :timed, default: true          # オプションを追加
      t.text :description
      t.string :color
      t.timestamps
    end
  end

end
