class AddUpDownToStorylines < ActiveRecord::Migration
  def change
    add_column :storylines, :upvotes, :integer

    add_column :storylines, :downvotes, :integer

  end
end
