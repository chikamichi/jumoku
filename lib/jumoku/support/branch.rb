module Jumoku
  # Namespacing. Useful for duck typing criteria.
  module Branch; end

  class UndirectedBranch < Plexus::Edge
    include Branch
  end

  class DirectedBranch   < Plexus::Arc
    include Branch
  end
end
