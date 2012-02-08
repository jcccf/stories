class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :comment
      t.string :url
      t.integer :user_id

      t.timestamps
    end
  end
end
