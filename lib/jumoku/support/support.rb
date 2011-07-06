module Jumoku
  # Base error class for the library.
  class JumokuError < StandardError; end

  # Raised in several circumstances when the basic constraints related
  # to a tree are not fulfilled (undirected, acyclic, connected).

  class RawTreeError < JumokuError; end
  # Error related to nodes.

  class RawTreeNodeError < RawTreeError; end
  # Raised if one attempts to add an already existing branch to a tree.

  class BranchAlreadyExistError < JumokuError; end
end
