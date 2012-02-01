class RemovePreviousFromStorylines < ActiveRecord::Migration
  def up
    remove_column :storylines, :previous
      end

  def down
    add_column :storylines, :previous, :integer
  end
end
