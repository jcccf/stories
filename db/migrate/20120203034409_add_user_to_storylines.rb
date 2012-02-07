class AddUserToStorylines < ActiveRecord::Migration  
  def change
    add_column :storylines, :user_id, :integer
  end
end
