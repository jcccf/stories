class Like < ActiveRecord::Base
  validates_uniqueness_of :user_id, :scope => [:storyline_id]
  belongs_to :user
  belongs_to :storyline
end
