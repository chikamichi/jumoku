module Jumoku
  # This module defines the minimum set of methods required to build a tree
  # which can use the algorithms defined in this library.
  #
  # A module based abiding to the TreeAPI must implement the following routines:
  #
  # * add_node!(n, l = nil) — adds a node to the tree and return the tree; l is an optional label (see Plexus library).
  # * add_branch!(i, j = nil, l = nil) — adds a branch to the tree and return the tree. i can be a {Branch}, or (i,j) a node pair; l is an optional label.
  # * remove_node!(n) — removes a node from the tree and return the tree.
  # * remove_branch!(i, j = nil) — removes an edge from the graph and return the tree. i can be a {Branch}, or (i,j) a node pair.
  # * nodes — returns an array of all nodes.
  # * terminal_nodes — returns an array of all terminal nodes.
  # * branches — returns an array of all branches.
  #
  module TreeAPI
    # @raise [JumokuError] if the API is not completely implemented
    #
    def self.included(klass)
      @api_methods ||= [:add_node!, :add_branch!, :remove_node!, :remove_branch!, :nodes, :terminal_nodes, :branches]
      ruby_18 { @api_methods.each { |m| m.to_s } }

      @api_methods.each do |meth|
        raise JumokuError, "Must implement #{meth}" unless klass.instance_methods.include?(meth)
      end
    end
  end
end
