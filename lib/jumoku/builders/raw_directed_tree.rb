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
      args = (params.pop if params.last.is_a? Hash) || {}
      strategies = _extract_strategies(args)

      super(*params) # Delegates to Plexus.

      class << self; self; end.module_eval do
        strategies.each { |strategy| include strategy }
        alias has_branch? has_arc?
      end
    end

    # Checks whether the tree is *really* a valid tree, that is if the
    # following conditions are fulfilled:
    #
    # * directed
    # * acyclic
    # * connected
    #
    # @return [Boolean]
    def valid?
      super and directed?
    end

    private

    def _branch_type
      DirectedBranch
    end
  end
end
