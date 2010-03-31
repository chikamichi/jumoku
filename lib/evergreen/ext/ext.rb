class Array
  # Takes a flat array of nodes pairs and yield
  # them to the block.
  def each_nodes_pair
    raise if self.size % 2 != 0
    each_by(2) { |pair| yield pair }
  end
end
