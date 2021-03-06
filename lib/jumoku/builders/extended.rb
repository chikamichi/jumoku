module Jumoku
  # This module provides methods extending the core implementation. Most of those
  # methods are cloning the receiver tree and perform their operation on the
  # duplicated object. Some other are helpers adding reflexivity to trees.
  # There are also a few in-place methods.
  #
  module Extended
    # Non destructive version of {RawTreeBuilder#add_node!} (works on a copy of the tree).
    #
    # @overload add_node!(n)
    #   @param [node] n
    # @overload add_node!(b)
    #   @param [Branch] b Branch[node i, node j, label l = nil]; if i (j) already exists, then j (i) must not exist
    # @return [Tree] a modified copy of `self`
    # @see RawTreeBuilder#add_node!
    #
    def add_node(n, l = nil)
      _clone.add_node!(n, l)
    end

    # Non destructive version {RawTreeBuilder#add_branch!} (works on a copy of the tree).
    #
    # @overload add_branch!(i, j, l = nil)
    #   @param [node] i
    #   @param [node] j
    #   @param [Label] l
    # @overload add_branch!(b)
    #   @param [Branch] b Branch[node i, node j, label l = nil]; if i (j) already exists, then j (i) must not exist
    # @return [Tree] a modified copy of `self`
    # @see RawTreeBuilder#add_branch!
    #
    def add_branch(i, j = nil, l = nil)
      _clone.add_branch!(i, j, l)
    end

    # Non destructive version of {RawTreeBuilder#remove_node!} (works on a copy of the tree).
    #
    # @param [node] n
    # @return [Tree] a modified copy of `self`
    # @see RawTreeBuilder#remove_node!
    #
    def remove_node(n)
      _clone.remove_node!(n)
    end

    # Non destructive version {RawTreeBuilder#remove_branch!} (works on a copy of the tree).
    #
    # You cannot remove non terminal branches as it would break the connectivity constraint
    # of the tree.
    #
    # @param [node] i
    # @param [node] j
    # @return [Tree] a modified copy of `self`
    # @see RawTreeBuilder#remove_branch!
    #
    def remove_branch(i, j = nil, *params)
      _clone.remove_branch!(i, j)
    end

    # Adds all specified nodes to the node set.
    #
    # The nodes defines implicit branches, that is it is mandatory to provide
    # an odd number of connected nodes which do not form cycles. You may specify
    # Branch objects within the list, though.
    #
    # Valid usage:
    #
    #     tree = Tree.new                # an empty tree
    #     tree.add_nodes!(1,2, 2,3, 3,4) # tree.nodes => [1, 2, 3, 4]
    #                                    # branches are (1-2), (2-3), (3-4)
    #     tree.add_nodes!(1,2, 2,3, Branch.new(3,4), 10,1)
    #     tree.add_nodes! [1,2, 2,3, 3,4]
    #
    # Invalid usages:
    #
    #     tree = Tree.new                # an empty tree
    #     tree.add_nodes!(1, 2, 3)       # even number of nodes
    #     tree.add_nodes!(1,2, 2,3, 3,1) # cycle
    #     tree.add_nodes!(1,2, 4,5)      # not connected
    #
    # A helper exist to make it easy to add nodes in a suite.
    # See {TreeBuilder#add_consecutive_nodes! add_consecutive_nodes!}.
    #
    # @param [#each] *a an Enumerable nodes set
    # @return [Tree] `self`
    #
    def add_nodes!(*a)
      a = a.flatten.expand_branches!
      if a.size == 1                                   # This allows for using << to add the root as well,
        if empty?                                      # so that you may write:
          add_node! a.only                             # Tree.new << :root << [:root, 1] << [1,2, 2,3, Branch.new(3,4)]...
        else
          raise RawTreeError, "Cannot add a node without a neighbour."
        end
      else
        a.expand_branches!.each_nodes_pair { |pair| add_branch! pair[0], pair[1] }
      end
      self
    end
    alias << add_nodes!

    # Same as {TreeBuilder#add_nodes! add_nodes!} but works on a copy of the receiver.
    #
    # @param [#each] *a an Enumerable nodes set
    # @return [Tree] a modified copy of `self`
    #
    def add_nodes(*a)
      _clone.add_nodes!(*a)
    end

    # Allows for adding consecutive nodes, each nodes being connected to their previous and
    # next neighbours.
    #
    # You may pass {Branch branches} within the nodes list.
    #
    #     Tree.new.add_consecutive_nodes!(1, 2, 3, :four, Branch.new(:foo, "bar")).branches
    #     # => (1=2, 2=3, 3=:four, :four=:foo, :foo="bar")
    #
    # @param [Array(nodes)] *a flat array of unique nodes
    # @return [Tree] `self`
    #
    def add_consecutive_nodes!(*a)
      # FIXME: really this may not be as efficient as it could be.
      # We may get rid of nodes duplication (no expand_branches!)
      # and add nodes by pair, shifting one node at a time from the list.
      add_nodes!(a.expand_branches!.create_nodes_pairs_list)
      self
    end

    # Same as {TreeBuilder#add_consecutive_nodes! add_consecutive_nodes!} but
    # works on a copy of the receiver.
    #
    # @param [Array(nodes)] *a flat array of unique nodes
    # @return [Tree] a modified copy of `self`
    #
    def add_consecutive_nodes(*a)
      _clone.add_consecutive_nodes!(*a)
    end

    # Adds all branches mentionned in the specified Enumerable to the branch set.
    #
    # Elements of the Enumerable can be either two-element arrays or instances of
    # {Branch}.
    #
    # @param [#each] *a an Enumerable branches set
    # @return [Tree] `self`
    #
    def add_branches!(*a)
      a.expand_branches!.each_nodes_pair { |pair| add_branch! pair[0], pair[1] }
      self
    end

    # Same as {TreeBuilder#add_branches! add_branches!} but works on a copy of the receiver.
    #
    # @param [#each] *a an Enumerable branches set
    # @return [Tree] a modified copy of `self`
    #
    def add_branches(*a)
      _clone.add_branches!(*a)
    end

    # Removes all nodes mentionned in the specified Enumerable from the tree.
    #
    # The process relies on {RawTreeBuilder#remove_node! remove_node!}.
    #
    # @param [#each] *nodes an Enumerable nodes set; may contain Range
    # @return [Tree] `self`
    #
    # @example
    #
    #   remove_nodes! 1, 3..5
    #
    def remove_nodes!(*nodes)
      nodes = nodes.to_a.map { |i| i.is_a?(Range) ? i.to_a : i }.flatten
      nodes.each { |v| remove_node! v }
      self
    end
    alias delete_nodes! remove_nodes!

    # Same as {TreeBuilder#remove_nodes! remove_nodes!} but works on a copy of the receiver.
    #
    # @param [#each] *a a node Enumerable set
    # @return [Tree] a modified copy of `self`
    #
    def remove_nodes(*a)
      _clone.remove_nodes!(*a)
    end
    alias delete_nodes remove_nodes

    # Removes all branches mentionned in the specified Enumerable from the tree.
    #
    # @param [#each] *a an Enumerable branches set
    # @return [Tree] `self`
    #
    def remove_branches!(*a)
      a.expand_branches!.each_nodes_pair { |pair| remove_branch! pair[0], pair[1] }
      self
    end
    alias delete_branches! remove_branches!

    # Same as {TreeBuilder#remove_branches! remove_branches!} but works on a copy of the receiver.
    #
    # @param [#each] *a an Enumerable branches set
    # @return [Tree] a modified copy of `self`
    # @see RawTreeBuilder#remove_branch!
    #
    def remove_branches(*a)
      _clone.remove_branches!(*a)
    end
    alias delete_branches remove_branches

    # Returns true if the specified node belongs to the tree.
    #
    # This is a default implementation that is of O(n) average complexity.
    # If a subclass uses a hash to store nodes, then this can be
    # made into an O(1) average complexity operation.
    #
    # @param [node] n
    # @return [Boolean]
    #
    def node?(n)
      nodes.include?(n)
    end
    alias has_node? node?

    # Returns true if all specified nodes belong to the tree.
    #
    # @param [nodes]
    # @return [Boolean]
    #
    def nodes?(*maybe_nodes)
      maybe_nodes.all? { |node| nodes.include? node }
    end
    alias has_nodes? nodes?

    # Returns true if any of the specified nodes belongs to the tree.
    #
    # @param [nodes]
    # @return [Boolean]
    #
    def nodes_among?(*maybe_nodes)
      maybe_nodes.any? { |node| nodes.include? node }
    end
    alias has_nodes_among? nodes_among?
    alias has_node_among?  nodes_among?
    # FIXME: these helpers could be backported into Plexus.

    # Returns true if i or (i,j) is a {Branch branch} of the tree.
    #
    # @overload branch?(a)
    #   @param [Branch] a
    # @overload branch?(i, j)
    #   @param [node] i
    #   @param [node] j
    # @return [Boolean]
    #
    def branch?(*args)
      branches.include?(edge_convert(*args))
    end
    alias has_branch? branch?

    # Returns true if the specified branches are a subset of or match exactly the
    # branches set of the tree (no ordering criterion).
    #
    # Labels are not part of the matching constraint: only connected nodes
    # matter in defining branch equality.
    #
    # @param [*Branch, *nodes] *maybe_branches a list of branches, either as Branch
    #   objects or as nodes pairs
    # @return [Boolean]
    #
    def branches?(*maybe_branches)
      maybe_branches.create_branches_list(_branch_type).all? do |maybe_branch|
        branches.any? do |branch|
          maybe_branch == branch
        end
      end
    end
    alias has_branches? branches?

    # Returns true if actual branches are included in the specified set of branches
    # (no ordering criterion).
    #
    # Labels are not part of the matching constraint: only connected nodes
    # matter in defining equality.
    #
    # @param [*Branch, *nodes] *maybe_branches a list of branches, either as Branch
    #   objects or as nodes pairs
    # @return [Boolean]
    #
    def branches_among?(*maybe_branches)
      list = maybe_branches.create_branches_list(_branch_type)
      branches.all? do |branch|
        list.any? do |maybe_branch|
          branch == maybe_branch
        end
      end
    end
    alias has_branches_among? branches_among?

    # Return the number of edges.
    #
    # @return [Integer]
    #
    #def size
      #edges.size
    #end

    # Number of nodes. Just `#nodes.size` really.
    #
    # @return [Integer]
    #
    def num_nodes
      nodes.size
    end
    alias number_of_nodes num_nodes

    # Number of branches.
    #
    # @return [Integer]
    #
    def num_branches
      branches.size
    end
    alias number_of_branches num_branches

    # Check whether all nodes from a list are leaves.
    #
    # @param [#to_a] nodes
    # @return [true, false]
    #
    def leaves?(*nodes)
      nodes.to_a.flatten.all? { |node| leaf?(node) }
    end
  end
end
