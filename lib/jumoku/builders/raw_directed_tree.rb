module Jumoku
  # A {RawDirectedTree} relax the undirected constraint of trees as defined in
  # Graph Theory. They remain connected and acyclic.
  #
  # It thus uses Plexus::DirectedGraphBuilder as its backend.
  #
  # It offers limited functionalities, therefore the main tree structure you'll likely to
  # use is its extended version, {Arborescence}.
  module RawDirectedTreeBuilder
    include Plexus::DirectedGraphBuilder
    include Shared

    # This method is called by the specialized implementations upon tree creation.
    #
    # Initialization parameters can include:
    #
    # * an array of branches to add
    # * one or several trees to copy (will be merged if multiple)
    #
    # @param *params [Hash] the initialization parameters
    # @return enhanced Plexus::DirectedGraph
    #
    def initialize(*params)
      super(*params) # Delegates to Plexus.
    end

    private

    def _branch_type
      DirectedBranch
    end
  end
end
