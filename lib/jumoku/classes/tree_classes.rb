module Jumoku
  # A generic {RawTreeBuilder RawTree} class you can inherit from.
  class RawTree; include RawTreeBuilder; end
  class RawDirectedTree; include RawDirectedTreeBuilder; end
  class Arborescence < RawDirectedTree; end

  # The main tree class to use. Fully-fledged tree structure with user-friendly public API.
  class Tree;    include TreeBuilder;    end
end
