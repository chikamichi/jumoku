module Jumoku
  # A {RawUndirectedTree} sticks to the standard definition of trees in Graph Theory:
  #  * undirected,
  #  * connected,
  #  * acyclic.
  # It thus uses Plexus::UndirectedGraphBuilder as its backend, which ensure the first
  # constraint.
  #
  # {RawUndirectedTreeBuilder} ensures the two remaining constraints are satisfied.
  # It offers limited functionalities, therefore the main tree structure you'll likely to
  # use is its extended version, {TreeBuilder}.
  #
  module RawUndirectedTreeBuilder
    include Plexus::UndirectedGraphBuilder
    include Shared

    # This method is called by the specialized implementations upon tree creation.
    #
    # Initialization parameters can include:
    #
    # * an array of branches to add
    # * one or several trees to copy (will be merged if multiple)
    #
    # @param *params [Hash] the initialization parameters
    # @return enhanced Plexus::UndirectedGraph
    #
    def initialize(*params)
      super(*params) # Delegates to Plexus.
      args = (params.pop if params.last.is_a? Hash) || {}
      @_options = args
      strategies = _extract_strategies(args)

      super(*params) # Delegates to Plexus.

      class << self; self; end.module_eval do
        strategies.each { |strategy| include strategy }
        alias has_branch? has_edge?
      end
    end

    # Checks whether the tree is *really* a valid tree, that is if the
    # following conditions are fulfilled:
    #
    # * undirected
    # * acyclic
    # * connected
    #
    # @return [Boolean]
    def valid?
      super && !directed?
    end

    private

    def _branch_type
      UndirectedBranch
    end
  end
end
