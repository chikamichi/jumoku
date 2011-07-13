module Jumoku
  module Strategies
    # A simple edge labeling strategy: as new nodes are added, new edges are
    # assigned increasing integers. Removed edges do not trigger reindexing,
    # so for a tree with n nodes, the labeling set is ||n|| but indexes are
    # not necessarily < n (indexing starts from 0).
    #
    # This simple strategy allows for using simple search algorithms as well
    # for simple ordering schemes.
    #
    module SimpleEdgeLabeling
      include Strategies::EdgeLabelingBackend

      attr_accessor :next_simple_edge_label_number

      # Override to handle an iterator for simple edge labeling. When a branch
      # is added, it is labeled with an OpenHash with one :_weight key which
      # value is an increasing integer. One may pass any custom label to the
      # method, which will be available under the :label key of the hash.
      #
      def add_branch!(u, v = nil, l = nil)
        self.next_simple_edge_label_number ||= 0
        label = OpenHash.new(:_weight => self.next_simple_edge_label_number)
        label.label = l unless l.nil?
        super(u, v, label)
        _edge_labeling_inc
      end

      # Sort edges by increasing weight number. If a block is provided, rely
      # on the backend implementation (#sort_by).
      #
      # @return [Array]
      #
      def sorted_edges(&block)
        return super(&block) if block_given?
        _sort_edges(edges)
      end

      # Sort a set of edges.
      #
      # @param [Array]
      # @return [Array]
      #
      def sort_edges(set)
        _sort_edges(set)
      end

      # Only for directed trees.
      #
      # Return the sorted list of arcs branched out from the specified node.
      #
      # @param [Node] node
      # @return [Array<Plexus::Arc>]
      #
      def sorted_arcs_from(node)
        return nil unless is_a? RawDirectedTreeBuilder
        adjacent(node).map do |child_node|
          edge_class[node, child_node, edge_label(node, child_node)]
        end.sort_by { |e| e.label._weight }
      end
      alias sorted_edges_from sorted_arcs_from # for lazy people

      # Only for directed trees.
      #
      # Return the sorted list of nodes branched out from the specified node.
      #
      # @param [Node] node
      # @return [Array<Node>]
      #
      def sorted_children_of(node)
        return nil unless is_a? RawDirectedTreeBuilder
        sorted_edges_from(node).map { |edge| edge.target }
      end

      private

      def _edge_labeling_inc
        self.next_simple_edge_label_number ||= 0
        self.next_simple_edge_label_number += 1
        super
      end

      def _sort_edges(set)
        set.sort { |a,b| a.label._weight <=> b.label._weight }
      end
    end
  end
end
