class StorylineLinks < ActiveRecord::Base

  def from_line
    Storyline.find(self.from_id)
  end
  
  def to_line
    Storyline.find(self.to_id)
  end

end
