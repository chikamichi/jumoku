module Jumoku
  # Strategies are decorators implemented as mixins which taint a tree object
  # with new or extended features. For instance, the `SimpleEdgeLabeling`
  # strategy alters the way new nodes and branches are added to a tree,
  # enforcing labeling of edges with increasing integers, `Binary` enforces
  # a tree to grow as a binary tree, etc.
  #
  # It is easy to develop your own decorators and `use` them.
  #
  module Strategies
    # Activate a strategy.
    #
    # @param [#to_s, Module] strategy strategy's name, either as a module
    #   namespace (like `Strategies::SimpleEdgeLabeling`) or a symbol (like
    #   `:simple_edge_labeling`)
    #
    def use(strategy)
      strategy = catch(:unknown_strategy) do
        begin
          if strategy.is_a?(Symbol) || strategy.is_a?(String)
            strategy = Strategies.const_get(strategy.to_s.constantize)
          end
        rescue NameError
          throw :unknown_strategy, nil
        end
        strategy
      end
      extend strategy unless strategy.nil?
    end
    alias strategy use
  end
end
