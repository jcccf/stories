require 'set'

namespace :graph do
  desc "export the graph"
  task :by_ids => :environment do
    print "Which IDs to export? "
    target_ids = $stdin.gets.split(" ").map { |i| i.to_i }

    target_ids.each do |id|
      
      filename = "log/graph_%06d.log" % id
      print "Generating %s ..." % filename

      nodes, edges = {}, []
      first_node = Storyline.find_by_id(id)
      nodes[id] = [first_node.created_at, first_node.line]
      linkstack = first_node.next_links
      while curr = linkstack.shift
        edges << [curr.from_id, curr.to_id]
        unless nodes.include? curr.to_id
          new_node = Storyline.find_by_id(curr.to_id)
          nodes[curr.to_id] = [new_node.created_at, new_node.line]
          linkstack += new_node.next_links
        end
      end

      File.open(filename, "w") do |f|
        # Print the nodes and date of creation
        f.puts "// Nodes"
        nodes.each do |k,v|
          f.puts "%d %d %s" % [k, v[0].strftime("%s"), v[1]]
        end

        # Print the edges
        f.puts "// Edges"
        edges.each do |u,v|
          f.puts "#{u} #{v}"
        end
      end

      puts "done!"
    end
    
  end
end