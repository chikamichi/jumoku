module Evergreen
  # This module defines the minimum set of functions required to make a tree that can
  # use the algorithms defined by this library.
  #
  # Each implementation module must implement the following routines:
  #
  #   * add_node!(n, l = nil)            Add a node to the tree and return the tree. `l` is an optional label.
  #   * add_branch!(p, c = nil, l = nil) Add a branch to the tree and return the tree. `p` can be an {Branch}, or `p,c` a {Branch} pair. The last parameter `l` is an optional label.
  #   * remove_node!(n)              Remove a vertex to the graph and return the tree.
  #   * remove_branch!(p, c = nil)       Remove an edge from the graph and return the tree.
  #   * nodes                       Returns an array of all nodes.
  #   * leaves                      Returns an array of all leaves.
  #   * branches                          Returns an array of all branches.
  module TreeAPI

    # @raise if the API is not completely implemented
    def self.included(klass)
      @api_methods ||= [:add_node!, :add_branch!, :remove_node!, :remove_branch!, :nodes, :terminal_nodes, :branches]
      ruby_18 { @api_methods.each { |m| m.to_s } }
      
      @api_methods.each do |meth| 
        raise "Must implement #{meth}" unless klass.instance_methods.include?(meth)
      end
    end

  end # TreeAPI
end # Evergreen
