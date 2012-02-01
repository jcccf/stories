class CreateStorylineLinks < ActiveRecord::Migration
  def change
    create_table :storyline_links do |t|
      t.integer :from_id
      t.integer :to_id

      t.timestamps
    end
  end
end
