class AddRootToStorylines < ActiveRecord::Migration
  def change
    add_column :storylines, :root, :boolean

  end
end
