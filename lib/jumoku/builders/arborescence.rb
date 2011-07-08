module Jumoku
  # This builder extends {RawDirectedTreeBuilder} implementation.
  #
  # It provides a directed tree which acts as a hierarchical structure, known
  # as an arborescence.
  #
  module ArborescenceBuilder
    include RawDirectedTreeBuilder
    include Extended
  end
end
