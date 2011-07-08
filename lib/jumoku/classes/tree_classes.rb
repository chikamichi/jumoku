module Jumoku
  # "Raw" implementations.
  class RawUndirectedTree; include RawUndirectedTreeBuilder; end
  class RawDirectedTree;   include RawDirectedTreeBuilder;   end

  # "Useful" implementations.
  class Tree;         include TreeBuilder;         end
  class Arborescence; include ArborescenceBuilder; end
end
