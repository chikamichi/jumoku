module Evergreen
  # Base error class for the library.
  class EvergreenError < StandardError; end

  # Raised in several circumstances when the basic constraints related
  # to a tree are not fulfilled (undirected, acyclic, connected).

  class RawTreeError < EvergreenError; end
  # Error related to nodes.

  class RawTreeNodeError < RawTreeError; end
  # Raised if one attempts to add an already existing branch to a tree.

  class BranchAlreadyExistError < EvergreenError; end
end
