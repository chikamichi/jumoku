module Evergreen
  # A generic {RawTreeBuilder RawTree} class you can inherit from.
  class RawTree; include RawTreeBuilder; end

  # The main tree class to use. Fully-fledged tree structure with user-friendly public API.
  class Tree;    include TreeBuilder;    end
end
