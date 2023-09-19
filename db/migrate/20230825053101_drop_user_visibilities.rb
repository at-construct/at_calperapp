class DropUserVisibilities < ActiveRecord::Migration[6.1]
  def up
    drop_table :user_visibilities
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
