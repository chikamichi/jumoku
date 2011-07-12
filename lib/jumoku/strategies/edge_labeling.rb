module Jumoku
  # Edge labeling strategies are concerned with the way edges or arcs are
  # labeled. Simple labeling schemes are based on indexing with increasing
  # integers, whereas some other strategies elaborate on notions such as
  # weight or symetry.
  #
  module EdgeLabeling
    # This module provides basic implementation for the common ground used
    # by custom strategies.
    #
    module Backend
      # Sort edges by the provided block's logic. The block takes edge as
      # parameter, and this method delegates to Enumerable#sort_by for
      # sorting edges. Return unsorted edges list if no block is provided.
      #
      # @return [Array]
      #
      def sorted_edges(&block)
        return edges.sort_by { |edge| block.call(edge) } if block_given?
        edges
      end

      private

      # Callback triggered when labeling a new edge. Does nothing by default.
      # Labeling strategies may implement their own logic and call super to
      # chain callbacks, or impose their behavior (caution!).
      #
      def _edge_labeling_inc
      end
    end
  end
end
