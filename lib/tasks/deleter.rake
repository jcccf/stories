require 'set'

namespace :deleter do
  desc "recursively delete a storyline"
  task :by_id => :environment do
    print "Which ID to recursively delete? "
    target_id = $stdin.gets.to_i
    
    # Collect all child stories and child links
    children, childlinks = Set.new, Set.new
    start = Storyline.find_by_id(target_id)
    children << start
    childlinks += start.next_links
    childlinks += start.prev_links
    linkstack = start.next_links
    while curr = linkstack.shift
      next_child = Storyline.find_by_id(curr.to_id)
      unless children.include? next_child
        children << next_child
        childlinks += next_child.next_links
        childlinks += next_child.prev_links
        linkstack += next_child.next_links
      end
    end
    print "You are going to delete #{children.size} nodes and #{childlinks.size} links! Are you sure? (y/n) "
    if $stdin.gets.chomp.to_s.downcase == 'y'
      children.each do |child|
        child.destroy
      end
      childlinks.each do |link|
        link.destroy
      end
      puts "Deleted all!"
    else
      puts "Did nothing."
    end
  end
end