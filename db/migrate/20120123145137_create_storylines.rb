class CreateStorylines < ActiveRecord::Migration
  def change
    create_table :storylines do |t|
      t.string :line
      t.integer :previous

      t.timestamps
    end
  end
end
