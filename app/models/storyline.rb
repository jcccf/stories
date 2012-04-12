class Storyline < ActiveRecord::Base
  belongs_to :user
  
  validates :line, :presence => true
  
  attr_accessor :prev, :next # Id of next storyline in that particular story (not necessarily set)
  
  def siblings
    if not @sibs
      raise "Prev not set for %s" % self.line unless self.prev
      @sibs = StorylineLinks.where('from_id = ?', self.prev).select { |n| n.to_id != self.id }
      @sibs_num = @sibs.size
    end
    @sibs
  end
  
  def num_siblings
    if not @sibs_num
      raise "Prev not set for %s" % self.line unless self.prev
      @sibs_num = StorylineLinks.where('from_id = ?', self.prev).size - 1
    end
    @sibs_num
  end
  
  def prev_links
    StorylineLinks.where('to_id = ?', self.id)
  end
  
  def next_links
    StorylineLinks.where('from_id = ?', self.id)
  end
  
  def insert_before(sline, add=false)
    sline.prev_links.update_all(:to_id => self.id) unless add
    StorylineLinks.new(:from_id => self.id, :to_id => sline.id).save
  end
  
  # Insert a line after sline in all paths if add is false
  # or add a new path if add is true
  def insert_after(sline, add=false)
    sline.next_links.update_all(:from_id => self.id) unless add
    StorylineLinks.new(:from_id => sline.id, :to_id => self.id).save
  end
  
  # Insert a line between s1 and s2 in all paths if add is false
  # or add a new path between s1 and s2 if add is true
  def insert_between(s1, s2, add=false)
    if not add
      if s1 and s2
        StorylineLinks.where('from_id = ? AND to_id = ?', s1, s2).update_all(:to_id => self.id)
      elsif s1
        insert_after(s1, add)
      elsif s2
        insert_before(s2)
      end
    else
      StorylineLinks.new(:from_id => s1.id, :to_id => self.id).save if s1
    end
    StorylineLinks.new(:from_id => self.id, :to_id => s2.id).save if s2
  end
  
  # Return a random continuation from the current Storyline,
  # starting with the lines corresponding to start_ids if provided
  # exclude ids listed in exclusions (after start_ids)
  def random_continuation(start_ids=[], exclusions=[], ordering=nil)
    puts "Excluding %d" % exclusions
    continuations, picked, old_picked = [], self, nil
    start_ids.each do |i|
      old_picked = picked
      picked = Storyline.find(i)
      Storyline.link(old_picked, picked)
      continuations << picked
    end
    
    # Get possible line after, in sorted id order
    nexts = picked.next_links
    if ordering and exclusions.size > 0 and nexts.size > 1
      nexts.sort { |a,b| a.to_id <=> b.to_id }
      pos = 0
      while true do
        break if exclusions.include? nexts[pos].to_id
        pos += 1
      end
      old_picked = picked
      picked = case ordering
      when "prev"
        nexts[(pos-1) % nexts.size].to_line
      when "next"
        nexts[(pos+1) % nexts.size].to_line
      else
        raise "Invalid Ordering"
      end
      Storyline.link(old_picked, picked)
      continuations << picked
    end
    
    # Order rest
    while true do
      nexts = picked.next_links.select {|n| not (exclusions.include? n.to_id) }
      puts nexts.inspect
      if nexts.size > 0
        old_picked = picked
        picked = nexts[rand(nexts.size)].to_line
        Storyline.link(old_picked, picked)
        continuations << picked
      else
        break
      end  
    end
    puts continuations.inspect
    continuations
  end
  
  def random_previous
    continuations, picked, old_picked = [self], self, nil
    while true do
      prevs = picked.prev_links
      if prevs.size > 0
        old_picked = picked
        picked = prevs[rand(prevs.size)].from_line
        Storyline.link(picked, old_picked)
        continuations << picked
      else
        break
      end
    end
    continuations.reverse
  end
  
  def upvotes_zero
    self.upvotes.nil? ? 0 : self.upvotes
  end
  
  # Up-vote a storyline
  def upvote
    self.upvotes ||= 0
    self.upvotes += 1
    self.save
  end
  
  def json_continuation_helper(seen_ids)
    datum = { :id => self.id, :line => self.line }
    datum[:lines] = []
    next_links.each do |link|
      if !seen_ids.has_key?(link.to_id)
        seen_ids[link.to_id] = true
        datum[:lines] << Storyline.find(link.to_id).json_continuation_helper(seen_ids)
      end
    end
    datum
  end
  
  def json_continuation
    # TODO This is kind of broken right now, need to show actual graph structure in the future
    json_continuation_helper({})
  end
  
  
  def json_continuation_d3
    id_to_index, counter = {}, 0
    data = { :nodes => [], :links => Set.new }
    lines_to_examine = [[self, 0]]
    while lines_to_examine.size > 0
      line, group = lines_to_examine.shift
      if !id_to_index.include? line.id
        id_to_index[line.id] = counter
        counter += 1
        data[:nodes] << { :name => line.line, :group => group, :stroke => (group > 0) ? 2 : 4, :real_id => line.id } # :age => 1
        
        # Add Plus
        data[:nodes] << { :name => "+", :group => group, :stroke => 2, :real_id => line.id, :parentIndex => id_to_index[line.id], :dashed => true }
        data[:links] << { :source => id_to_index[line.id], :target => id_to_index[line.id]+1, :value => 0.8 + ((line.line.size+50)/100) }
        counter += 1
        
      end
      line.prev_links.each do |link|
        if id_to_index.include? link.from_id
          data[:links] << { :source => id_to_index[link.from_id], :target => id_to_index[link.to_id], :value => 2 + (line.line.size/50) }
        end
      end
      line.next_links.each do |link|
        lines_to_examine << [link.to_line, group+1] unless id_to_index.include? link.to_id
      end
    end
    data[:links] = data[:links].to_a
    data
  end
  
  #
  # Class Methods
  #
  
  def self.roots
    #Storyline.all
    Storyline.where(:root => true)
  end
  
  def self.random
    if (c = count) != 0
      Storyline.find(:first, :offset => rand(c))
    end
  end
  
  def self.link(first, second)
    first.next = second.id
    second.prev = first.id
  end
  
end