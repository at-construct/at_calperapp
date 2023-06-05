class AddSelectedToParticipants < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :selected, :boolean, default: true
  end
end
