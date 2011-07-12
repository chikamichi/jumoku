module Jumoku
  # "Raw" implementations.

  # See {RawUndirectedTreeBuilder}.
  class RawUndirectedTree; include RawUndirectedTreeBuilder; end
  # See {RawDirectedTreeBuilder}.
  class RawDirectedTree;   include RawDirectedTreeBuilder;   end

  # "Useful" implementations.

  # See {TreeBuilder}.
  class Tree;         include TreeBuilder;         end
  # See {ArborescenceBuilder}.
  class Arborescence; include ArborescenceBuilder; end
end
