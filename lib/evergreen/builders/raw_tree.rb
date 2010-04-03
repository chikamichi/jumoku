module Evergreen
  # This module provides the basic routines needed to implement the specialized builders:
  # {TreeBuilder}, {BinaryTreeBuilder}, … each of them streamlining {RawTreeBuilder}'s
  # behavior. Those implementations are under the control of the {TreeAPI}.
  #
  # A {RawTree} sticks to the standard definition of trees in Graph Theory: undirected,
  # connected, acyclic graphs. Using Graphy::UndirectedGraphBuilder as its backend, 
  # {RawTreeBuilder} ensures the two remaining constraints are satisfied (connected and
  # acyclic). {RawTreeBuilder RawTree} offers limited functionalities, therefore the main
  # tree structure you'll likely to use is its extended version, {TreeBuilder Tree}. A
  # {Tree} share the same behavior but is a fully-fledged object with user-friendly public
  # methods built upon {RawTree}'s internals.
  #
  # Note that a node can be any Object. There is no "node type", therefore arguments which
  # are expected to be nodes are simply labelled as "`node`". A nice object type to us as
  # a node would be an OpenStruct or an
  # [OpenObject](http://facets.rubyforge.org/apidoc/api/more/classes/OpenObject.html)
  # (from the Facets library), as it turns nodes into versatile handlers.
  #
  # This builder defines a few methods not required by the API so as to maintain consistency
  # in the DSL.
  module RawTreeBuilder
    include Graphy::UndirectedGraphBuilder

    # This method is called by the specialized implementations
    # upon tree creation.
    #
    # Initialization parameters can include:
    #
    # * an array of branches to add
    # * one or several trees to copy (will be merged if multiple)
    #
    # @param *params [Hash] the initialization parameters
    # @return [RawTree]
    def initialize(*params)
      class << self
        self
      end.module_eval do
        # Ensure the builder abides by its API requirements.
        include Evergreen::TreeAPI
      end
      super(*params) # Delegates to Graphy.
    end

    # Ensure trees are seen as undirected graphs.
    #
    # @return [Boolean] false
    def directed?
      return false
    end
    # FIXME: should be able to reach Graphy's method ?!

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
      elsif u.is_a? Evergreen::Branch
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
    def add_branch! u, v = nil, l = nil
      if has_node? u and has_node? v
        unless has_branch? u, v
          # Ensure the acyclic constraint.
          raise RawTreeError, "Can't form a cycle within a tree."
        end
      end

      # TODO: DRY this up.
      if u.is_a? Evergreen::Branch
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
      if terminal? u or force
        remove_vertex! u
      else
        # Ensure the connected constraint.
        raise RawTreeError, "Can't remove a non terminal node in a tree"
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
      if u.is_a? Evergreen::Branch
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
      nodes.inject([]) do |t_nodes, node| 
        t_nodes << node if terminal?(node)
        t_nodes # must return t_nodes explicitily because
                # (rubydoc Enumerable#inject) "at each step, memo is set to the value returned by the block"
                # (sets t_nodes to nil otherwise).
      end
    end
    alias boundaries terminal_nodes

    # The branches of the tree in a 1D array.
    #
    # @return [Array(Branch)]
    def branches
      edges
    end

    # Aliasing.
    alias has_node? has_vertex?
    alias has_branch? has_edge?

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
      acyclic? and connected? and not directed?
    end

    # Is the node a terminal node?
    #
    # @return [Boolean]
    def terminal? u
      if has_node? u
        # root is always terminal, otherwise check whether degree is unitary
        nodes == [u] ? true : (degree(u) == 1)
      else
        raise RawTreeNodeError, "Not a node of this tree."
      end
    end
    alias has_terminal_node? terminal?

    # Is the tree empty?
    #
    # @return [Boolean]
    def empty?
      nodes.empty?
    end
  end
end
