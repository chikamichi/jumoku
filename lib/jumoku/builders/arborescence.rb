module Jumoku
  # This builder extends {RawDirectedTreeBuilder} implementation.
  #
  # It provides a directed tree which acts as a hierarchical structure, known
  # as an arborescence.
  #
  module ArborescenceBuilder
    include RawDirectedTreeBuilder
    include Extended

    def root
      return nodes.first if nodes.size == 1
      nodes.find { |node| in_degree(node) == 0 && out_degree(node) > 0 }
    end

    def root_edges
      adjacent(root, :type => :edges)
    end

    def leaves
      terminal_nodes.delete_if do |node|
        out_degree(node) > 0
      end
    end

    def leaf?(node)
      terminal?(node) && out_degree(node) == 0
    end

    def leaves?(*nodes)
      nodes.to_a.flatten.all? { |node| leaf?(node) }
    end
  end
end
