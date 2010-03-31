module Evergreen
  # A generic {RawTreeBuilder RawTree} class you can inherit from.
  class RawTree; include RawTreeBuilder; end
  class Tree;    include TreeBuilder;    end
end
