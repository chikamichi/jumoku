module Jumoku
  module EdgeLabeling
    module Backend
      # Sort edges by the provided block's logic. The block takes edge as
      # parameter, and this method delegates to Enumerable#sort_by for
      # sorting edges. Return unsorted edges list if no block is provided.
      #
      # @return [Array]
      #
      def sort_edges(&block)
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
