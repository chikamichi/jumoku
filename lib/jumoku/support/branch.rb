module Jumoku
  # Used only as a namespace. Useful for duck typing criteria: both
  # `Plexus::Edge` and `Plexus::Arc` are seen as `Branch`.
  #
  module Branch; end

  # Delegates to `Plexus::Edge`.
  #
  class UndirectedBranch < Plexus::Edge
    include Branch
  end

  # Delegates to `Plexus::Arc`.
  #
  class DirectedBranch   < Plexus::Arc
    include Branch
  end
end
