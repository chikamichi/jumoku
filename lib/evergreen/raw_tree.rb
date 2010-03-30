module Evergreen
  # This module provides the basic routines needed to implement the specialized builders:
  # {TreeBuilder}, {BinaryTreeBuilder}, … each of them streamlining {RawTreeBuilder}'s
  # behavior. Those implementations are under the control of the {TreeAPI}.
  #
  # A {RawTree} sticks to the standard definition of trees in Graph Theory: undirected,
  # connected, acyclic graphs. Using Graphy::UndirectedGraphBuilder as its backends, 
  # {RawTreeBuilder} ensures the two remaining constraints are satisfied (connected and
  # acyclic).
  #
  # Note that a node can be any Object. There is no "node type", therefore arguments which
  # are expected to be nodes are simply labelled as "`node`". A nice object type to us as
  # a node would be an OpenStruct or an OpenObject (from the Facets library), as it makes
  # nodes versatile handlers.
  #
  # This builder defines a few methods not required by the API so as to maintain consistency
  # in the DSL (for instance, aliasing `*vertex` to `*node`, etc.)
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
    #def implementation_initialize(*params)
    def initialize(*params)
      raise ArgumentError if params.any? do |p|
        # FIXME: checking wether it's a GraphBuilder (module) is not sufficient
        # and the is_a? redefinition trick (instance_evaling) should be
        # completed by a clever way to check the actual class of p.
        # Maybe using ObjectSpace to get the available Graph classes?
        !(p.is_a? Evergreen::RawTreeBuilder or p.is_a? Array or p.is_a? Hash)
      end

      args = params.last || {}

      class << self
        self
      end.module_eval do
        # Ensure the builder abides by its API requirements.
        include Evergreen::TreeAPI
      end

      super # Delegates to Graphy then.
    end

    # By definition, a tree is undirected.
    #
    # @return [Boolean] false
    def directed?
      return false
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
    # As a tree is an undirected structure, the order of the parameter is of
    # no importance : `add_branch!(u,v) == add_branch!(v,u)`.
    #
    # @overload add_branch!(i, j)
    #   @param [node] i
    #   @param [node] j there is no order constraint on the nodes couple
    # @overload add_branch!(b)
    #   @param [Branch] b Branch[node i, node j, label l = nil]; if i (j) already exists, then j (i) must not exist
    # @return [RawTree] self
    def add_branch! u, v = nil
      if has_node? u and has_node? v
        unless has_branch? u, v
          # Ensure the acyclic constraint.
          raise RawTreeError, "Can't form a cycle within a tree."
        end
      end

      if u.is_a? Evergreen::Branch
        v = u.target
        u = u.source
      end

      if has_node? u or has_node? v or nodes.empty?
        add_edge! u, v
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
    def remove_node! u
      if terminal? u
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
    def remove_branch! u, v = nil, *params
      options = params.last || {}
      options.reverse_merge! :force => false

      # FIXME: as it is the ! version, this make no sense to have the
      # :force option here, but I'll keep it for the safe version.
      if options[:force]
        if has_node? u and has_node? v
          if terminal? u and terminal? v
            remove_edge! u, v
          elsif terminal? u and not terminal? v
            remove_node! u
          elsif terminal? v and not terminal? u
            remove_node! v
          else
            raise RawTreeError, "Can't remove a non terminal branch in a tree"
          end
        else
          raise RawTreeError, "Can't remove a branch which does not exist"
        end
      else
        # Ensure some safety somehow.
        raise RawTreeError, "Can't remove a branch from a tree without being forced to (option :force)"
      end
    end

    # The nodes of the tree in a 1D array.
    #
    # @returns [Array(node)]
    def nodes
      vertices
    end

    # The terminal nodes of the tree in a 1D array.
    #
    # @return [Array(node)] only terminal nodes
    def terminal_nodes
      nodes.inject(0) { |num, node| num += 1 if terminal?(node)}
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
        nodes == [u] ? true : (degree(u) == 1)
      else
        raise RawTreeNodeError, "Not a node of this tree."
      end
    end
    alias has_terminal_node? terminal?
  end
end
