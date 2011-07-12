module Jumoku
  # This builder extends {RawDirectedTreeBuilder} implementation.
  #
  # It provides a directed tree which acts as a hierarchical structure, known
  # as an arborescence.
  #
  # By default, it is ensured that new arcs remain in the same general flow
  # direction, based on the first arc added (binding the node known as root
  # to its first children, known as leaf). This constraint may be relaxed by
  # passing the `:free_flow` option to true when initializing:
  #
  #     Arborescence.new(:free_flow => true)
  #
  # This way, the tree remains directed (nodes are bound using arcs, not
  # undirected edges), but a node may be either a pure source (only outing
  # arcs), a pure target (only arcs pointing at it), or a mix.
  #
  module ArborescenceBuilder
    include RawDirectedTreeBuilder
    include Extended

    def add_branch!(u, v = nil, l = nil)
      return super(u,v,l) if @_options[:free_flow]
      return add_branch!(u.source, u.target, l) if u.is_a? _branch_type
      return super(u,v,l) if nodes.size < 2

      nodes.include?(u) ? super(u,v,l) : super(v,u,l)
    end

    # Find the root node.
    #
    # @return [Node]
    #
    def root
      return nodes.first if nodes.size == 1
      nodes.find { |node| root?(node) }
    end

    # Return the list of arcs branched out from the root node.
    #
    # @return [Array<Plexus::Arc>]
    #
    def root_edges
      adjacent(root, :type => :edges)
    end

    # Check whether a node is the root.
    #
    # @return [true, false]
    #
    def root?(node)
      in_degree(node) == 0 && out_degree(node) > 0
    end

    # Return the list of a node's children.
    #
    # @param [Node] node
    # @return [Array<Node>]
    #
    def children(parent)
      adjacent(parent)
    end
    alias children_of children

    # Return the parent node of another.
    #
    # @param [Node] node
    # @raise if the node has more than one parent (should never occur!)
    # @return [Node, nil] nil if the node is root
    #
    def parent(node)
      parent = adjacent(node, :direction => :in)
      raise JumokuError, "Inconsistent directed tree (more than one parent for the node!)" if parent.size > 1
      parent.empty? ? nil : parent.first
    end
    alias parent_of parent

    # Check whether a node is a parent. If another node is provided as
    # second parameter, check whether the former node is the parent of the
    # latter node.
    #
    # @overload parent?(node)
    #   @param [Node] node
    #   @return [true, false]
    # @overload parent?(node, maybe_child)
    #   @param [Node] node
    #   @param [Node] maybe_child
    #   @return [true, false]
    #
    def parent?(node, maybe_child = nil)
      if maybe_child.nil?
        !children(node).empty?
      else
        children(node).include? maybe_child
      end
    end

    # Return the siblings for a node. Siblings are other node's parent children.
    #
    # @param [Node] node
    # @return [Array<Node>] empty list if the node is root
    #
    def siblings(node)
      return [] if root?(node)
      siblings = children(parent(node))
      siblings.delete(node)
      siblings
    end
    alias siblings_of siblings

    # Check whether two nodes are siblings.
    #
    # @param [Node] node1
    # @param [Node] node2
    # @return [true, false]
    #
    def siblings?(node1, node2)
      siblings(node1).include?(node2)
    end

    # Return the list of a node's neighbours, that is, children of node's
    # parent siblings (cousins).
    #
    # @param [Node] node
    # @param [Hash] options
    # @option options [true, false] :siblings whether to include the node's
    #   siblings in the list
    # @return [Array<Node>]
    #
    def neighbours(node, options = {:siblings => false})
      # special case when the node is the root
      return [] if root?(node)

      # special case when the node is a root's child
      if root?(parent(node))
        nghb = children(parent(node))
        nghb.delete_if { |child| child == node } unless options[:siblings]
        return nghb.map { |child| [child] }
      end

      # general case
      nghb = siblings(parent(node)).map do |sibling|
        children(sibling)
      end
      nghb << siblings(node) if options[:siblings]
      nghb
    end
    alias cousins neighbours

    # Check whether two nodes are neighbours. To include the node's siblings
    # in the matching candidates, pass the `:siblings` option to true.
    #
    # @param [Node] node1
    # @param [Node] node2
    # @param [Hash] options
    # @option options [true, false] :siblings whether to include the node's
    #   siblings in the list
    # @return [true, false]
    #
    def neighbours?(node1, node2, options = {:siblings => false})
      neighbours(node1, options).any? { |set| set.include? node2 }
    end
    alias cousins? neighbours?

    # Return the list of leaf nodes.
    #
    # @return [Array<Node>]
    #
    def leaves
      terminal_nodes.delete_if do |node|
        out_degree(node) > 0
      end
    end

    # Check whether a node is a leaf.
    #
    # @param [Node]
    # @return [true, false]
    #
    def leaf?(node)
      terminal?(node) && out_degree(node) == 0
    end

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
