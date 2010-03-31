module Evergreen
  # This builder extends the cheap implementation {RawTreeBuilder}, which
  # purpose is to implement the {TreeAPI}. {TreeBuilder} provides extended
  # functionalities and acts as the main tree structure you may use, either
  # by mixing-in this module or by inheritance of the associated {Tree} class.
  #
  #     tree = Tree.new
  #
  #     # or
  #
  #     class MyTree < Tree
  #       # your stuff
  #     end
  #     tree = MyTree.new
  #
  #     # or
  #
  #     class MyTree
  #       include TreeBuilder
  #       # your stuff
  #     end
  #     tree = MyTree.new
  module TreeBuilder
    include RawTreeBuilder

    def initialize(*params)
      super(*params)
    end
   
    # Non destructive version of {RawTreeBuilder#add_node!} (works on a copy of the tree).
    #
    # @param [node] n
    # @param [Label] l
    # @return [Tree] a new tree with the supplementary node
    def add_node(n, l = nil)
      x = self.class.new(self)
      x.add_node!(n, l)
    end

    # Non destructive version {RawTreeBuilder#add_branch!} (works on a copy of the tree).
    #
    # @param [node] i
    # @param [node] j
    # @param [Label] l
    # @return [Tree] a new tree with the supplementary branch
    def add_branch(i, j = nil, l = nil)
      x = self.class.new(self)
      x.add_branch!(i, j, l)
    end

    # Non destructive version of {RawTreeBuilder#remove_node!} (works on a copy of the tree).
    #
    # @param [node] n
    # @return [Tree] a new tree without the specified node
    def remove_node(n)
      x = self.class.new(self)
      x.remove_node!(n)
    end

    # Non destructive version {RawTreeBuilder#remove_branch!} (works on a copy of the tree).
    #
    # You cannot remove non terminal branches as it would break
    # the connectivity constraint of the tree.
    #
    # @param [node] u
    # @param [node] v
    # @return [Tree] a new tree without the specified branch
    def remove_branch(u, v = nil, *params)
      options = params.last || {}
      options.reverse_merge! :force => false

      if options[:force]
        x = self.class.new(self)
        x.remove_branch!(u, v)
      else
        # Ensure some safety somehow.
        raise RawTreeError, "Can't remove a branch from a tree without being forced to (option :force)."
      end
    end
    
    # Adds all specified nodes to the node set.
    #
    # The nodes defines implicit branches, that is it is mandatory to provide
    # an odd number of connected nodes which does not form a cycle.
    #
    # Valid usage:
    # 
    #     tree = Tree.new                # an empty tree
    #     tree.add_nodes!(1,2, 2,3, 3,4) # tree.nodes => [1, 2, 3, 4]
    #
    # Invalid usages:
    #
    #     tree = Tree.new                # an empty tree
    #     tree.add_nodes!(1, 2, 3)       # even number of nodes
    #     tree.add_nodes!(1,2, 2,3, 3,1) # cycle
    #     tree.add_nodes!(1,2, 4,5)      # not connected
    #
    # @param [#each] *a an Enumerable nodes set
    # @return [Tree] `self`
    def add_nodes!(*a)
      #a.each { |v| add_node! v }
      
      # let's expand the branches first
      tmp = a.dup
      branches_positions = tmp.map_send(:"is_a?", Evergreen::Branch).map_with_index { |e,i| i if e == true }.compact
      branches_positions.each do |pos|
        branch = a.delete_at pos
        a.insert pos,   branch.source
        a.insert pos+1, branch.target
      end

      begin
        a.each_nodes_pair do |pair|
          add_branch! pair[0], pair[1]
        end
      rescue Exception
        # FIXME: well maybe it should not raise and let add_branch! do the checks?
        raise RawTreeError, "Adding those nodes would break the tree structure."
      end
      self
    end

    # Same as {TreeBuilder#add_nodes! add_nodes!} but works on copy of the receiver.
    #
    # @param [#each] *a
    # @return [Tree] a modified copy of `self`
    def add_nodes(*a)
      x = self.class.new(self)
      x.add_nodes(*a)
      self
    end

    # Adds all branches mentionned in the specified Enumerable to the branch set.
    #
    # Elements of the Enumerable can be either two-element arrays or instances of
    # {Branch}.
    #
    # @param [#each] *a an Enumerable branches set
    # @return [Tree] `self`
    def add_branches!(*a)
      a.each { |branch| add_branch!(branch) }
      self
    end

    # Same as {TreeBuilder#add_branches! add_branches!} but works on a copy of the receiver.
    #
    # @param [#each] *a an Enumerable branches set
    # @return [Tree] a modified copy of `self`
    def add_branches(*a)
      x = self.class.new(self)
      x.add_branches!(*a)
      self
    end

    # Removes all nodes mentionned in the specified Enumerable from the tree.
    #
    # The process relies on {RawTreeBuilder#remove_node! remove_node!}.
    #
    # @param [#each] *a an Enumerable nodes set
    # @return [Tree] `self`
    def remove_nodes!(*a)
      a.each { |v| remove_node! v }
    end
    alias delete_nodes! remove_nodes!

    # Same as {RawTreeBuilder#remove_nodes! remove_nodes!} but works on a copy of the receiver.
    #
    # @param [#each] *a a node Enumerable set
    # @return [Tree] a modified copy of `self`
    def remove_nodes(*a)
      x = self.class.new(self)
      x.remove_nodes(*a)
    end
    alias delete_nodes remove_nodes

    # Removes all branches mentionned in the specified Enumerable from the tree.
    #
    # The process relies on {RawTreeBuilder#remove_branches! remove_branches!}.
    #
    # @param [#each] *a an Enumerable branches set
    # @return [Tree] `self`
    def remove_branches!(*a)
      # FIXME: isn't that broken (infinite loop)?
      puts "test"
      a.each { |e| remove_branch! e }
    end
    alias delete_branches! remove_branches!

    # Same as {TreeBuilder#remove_branches! remove_branches!} but works on a copy of the receiver.
    #
    # @param [#each] *a an Enumerable branches set
    # @return [Tree] a modified copy of `self`
    def remove_branches(*a)
      x = self.class.new(self)
      x.remove_branches!(*a)
    end
    alias delete_branches remove_branches

    # Returns true if the specified node belongs to the tree.
    #
    # This is a default implementation that is of O(n) average complexity.
    # If a subclass uses a hash to store nodes, then this can be
    # made into an O(1) average complexity operation.
    #
    # @param [node] v
    # @return [Boolean]
    def node?(v)
      nodes.include?(v)
    end
    alias has_node? node?
    # TODO: (has_)nodes?

    # Returns true if u or (u,v) is an {Branch branch} of the tree.
    #
    # @overload branch?(a)
    #   @param [Branch] a
    # @overload branch?(u, v)
    #   @param [node] u
    #   @param [node] v
    # @return [Boolean]
    def branch?(*args)
      branches.include?(edge_convert(*args))
    end  
    alias has_branch? branch?
    
    # Number of nodes.
    #
    # @return [Integer]
    def num_nodes
      nodes.size
    end
    alias number_of_nodes num_nodes

    # Number of branches.
    #
    # @return [Integer]
    def num_branches
      branches.size
    end
    alias number_of_branches num_branches
  end
end
