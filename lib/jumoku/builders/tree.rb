module Jumoku
  # This builder extends {RawUndirectedTreeBuilder} implementation.
  #
  # It provides an undirected tree which acts as a hierarchical structure,
  # known as a tree.
  #
  module TreeBuilder
    include RawUndirectedTreeBuilder
    include Extended
  end
end
