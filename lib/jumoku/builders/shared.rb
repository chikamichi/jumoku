module Jumoku
  # This module provides the basic routines needed to implement the specialized
  # builders: {UndirectedTreeBuilder} and {DirectedTreeBuilder}.
  #
  module Shared
    def self.included(base)
      base.class_eval do
        # Late aliasing as it references methods provided by Plexus modules.
        alias has_node? has_vertex?
      end
    end

    # Adds the node to the tree.
    #
    # For convenience, you may pass a branch as the parameter,
    # which one node already exists in the tree and the other is
    # to be added.
    #
    # @overload add_node!(n)
    #   @param [node] n
    # @overload add_node!(b)
    #   @param [Branch] b Branch[node i, node j, label l = nil]; if i (j) already exists, then j (i) must not exist
    # @return [RawTree] self
    def add_node! u, v = nil
      if nodes.empty?
        add_vertex! u
      elsif u.is_a? _branch_type
        add_branch! u
      elsif not v.nil?
        add_branch! u, v
      else
        # Ensure the connected constraint.
        raise RawTreeError, "In order to add a node to the tree, you must specify another node to attach to."
      end
    end

    # Adds a new branch to the tree.
    #
    # As a tree is an undirected structure, the order of the parameters is of
    # no importance, that is: `add_branch!(u,v) == add_branch!(v,u)`.
    #
    # @overload add_branch!(i, j, l = nil)
    #   @param [node] i
    #   @param [node] j
    #   @param [Label] l
    # @overload add_branch!(b)
    #   @param [Branch] b Branch[node i, node j, label l = nil]; if i (j) already exists, then j (i) must not exist
    # @return [RawTree] self
    #
    def add_branch! u, v = nil, l = nil
      if has_node? u and has_node? v
        unless has_branch? u, v
          # Ensure the acyclic constraint.
          raise ForbiddenCycle, "Can't form a cycle within a tree."
        end
      end

      # TODO: DRY this up.
      if u.is_a? _branch_type
        v = u.target
        u = u.source
      end

      if has_node? u or has_node? v or nodes.empty?
        add_edge! u, v, l
      else
        # Ensure the connected constraint.
        raise RawTreeError, "Can't add a dead branch to a tree."
      end
    end

    # Removes a node from the tree.
    #
    # You cannot remove non terminal nodes as it would break the
    # connectivity constraint of the tree.
    #
    # I may add an option which would allow to force removal
    # of internal nodes and return two new trees from this
    # destructive operation.
    #
    # @param [node] u
    # @return [RawTree] self
    def remove_node!(u, force = false)
      if force || terminal?(u)
        remove_vertex! u
      else
        # Ensure the connected constraint.
        raise UndefinedNode, "Can't remove a non terminal node in a tree"
      end
    end

    # Removes a branch from the tree.
    #
    # You cannot remove non terminal branches as it would break
    # the connectivity constraint of the tree.
    #
    # I may add an option which would allow to force removal
    # of internal nodes and return two new trees from this
    # destructive operation.
    #
    # @overload remove_branch!(i, j)
    #   @param [node] i
    #   @param [node] j
    # @overload remove_branch!(b)
    #   @param [Branch] b
    # @return [RawTree] self
    def remove_branch! u, v = nil
      if u.is_a? _branch_type
        v = u.target
        u = u.source
      end

      if has_node? u and has_node? v
        if terminal? u and terminal? v
          remove_edge! u, v
          # empty the tree if u and v are the last two nodes, for they're
          # not connected anymore
          if [u, v].all? { |node| nodes.include? node } and nodes.size == 2
            remove_node! u, true
            remove_node! v, true
          end
        elsif terminal? u and not terminal? v
          remove_node! u
        elsif terminal? v and not terminal? u
          remove_node! v
        else
          raise RawTreeError, "Can't remove a non terminal branch in a tree."
        end
      else
        raise RawTreeError, "Can't remove a branch which does not exist."
      end
    end
    # TODO: add an option to force nodes deletion upon branch deletion
    # (:and_nodes => true) ; called by a wrapping method
    # remove_branch_and_nodes, alias break_branch
    # (and their ! roomates).

    # The nodes of the tree in a 1D array.
    #
    # @return [Array(node)]
    def nodes
      vertices
    end

    # The terminal nodes of the tree in a 1D array.
    #
    # @return [Array(node)] only terminal nodes (empty array if no terminal nodes,
    #   but should never happen in a tree).
    def terminal_nodes
      nodes.inject([]) do |terminals, node|
        terminals << node if terminal?(node)
        terminals
      end
    end
    alias boundaries terminal_nodes
    alias leaves terminal_nodes

    # The branches of the tree in a 1D array.
    #
    # @return [Array(Branch)]
    def branches
      edges
    end

    # Tree helpers.

    # Checks whether the tree is *really* a valid tree, that is if the
    # following conditions are fulfilled:
    #
    # * undirected
    # * acyclic
    # * connected
    #
    # @return [Boolean]
    def valid?
      acyclic? and connected?
    end

    # Is the node a terminal node?
    #
    # @return [Boolean]
    def terminal? u
      if has_node? u
        # root is always terminal, otherwise check whether degree is unitary
        nodes == [u] ? true : (degree(u) == 1)
      else
        raise UndefinedNode, "Not a node of this tree."
      end
    end
    alias has_terminal_node? terminal?
    alias leaf? terminal?

    # Is the tree empty?
    #
    # @return [Boolean]
    def empty?
      nodes.empty?
    end

    private

    # Do *not* call cloning method on a cloned tree, as it will trigger
    # an infinite cloning loop.
    #
    # TODO: add support for a global CLONING flag (defaults: true). If set
    # to false, _clone would just return self, so that #add_node would behave
    # like #add_node! for instance.
    #
    # @return [Tree] cloned tree
    #
    def _clone
      self.class.new(self)
    end
  end
end
