class Array
  # Takes a flat array of nodes pairs and yield
  # them to the block.
  def each_nodes_pair
    raise if self.size % 2 != 0
    each_by(2) { |pair| yield pair }
  end

  # Fetches the positions of Branch items in an array,
  # and expands them in place as nodes pairs.
  #
  #     expand_branches!(1,2, Branch.new(2, 3), 3,4, 4,5)
  #     # => 1,2, 2,3, 3,4, 4,5
  #
  # @param [*nodes, *Branch] *a a flat list of nodes pairs and branches
  # @return [*nodes] a flat list of nodes pairs
  def expand_branches!
    branches_positions = self.dup.map_send(:"is_a?", Evergreen::Branch).map_with_index { |e,i| i if e == true }.compact
    # obviously positions will gain an offset of 1 for each expanded branch,
    # so let's correct this right away
    branches_positions = branches_positions.map_with_index { |e,i| e += i }
    branches_positions.each do |pos|
      branch = self.delete_at pos
      self.insert pos,   branch.source
      self.insert pos+1, branch.target
    end
    return self
  end

  def create_pairs
    self.map_with_index { |e,i| ((pairs ||= []) << e).concat(self.values_at(i+1)) }[0..-2]
  end

  # Creates nodes pairs from a flat array specifying unique nodes.
  #
  #     b = [1, 2, 3, "foo", :bar, Array.new]
  #     b.create_nodes_pairs
  #     => [1, 2, 2, 3, 3, "foo", "foo", :bar, :bar, []]
  #
  # @return [Array(nodes)]
  def create_nodes_pairs_list
    self.create_pairs.flatten(1)
  end

  def create_branches_list
    branches = []
    self.expand_branches!.each_by(2) { |pair| branches << Evergreen::Branch.new(pair[0], pair[1]) }
    branches
  end
end
