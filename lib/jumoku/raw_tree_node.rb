module Jumoku
  module RawTree

    # This module describes a raw tree node.
    #
    # You can include it in a class of your own to make it act
    # as a raw tree node, while customizing behaviors.
    module Node

      # Creates a new node.
      #
      # @param [#to_s, #to_sym] name a valid name, considering the :names_as options
      #   passed to the raw tree you want to create a node for.
      # @param [Object] data the data field type to use. Defaults to an empty OpenObject
      # @param [Array(#to_s)] children an array of children nodes ids
      #
      # @return [OpenObject] the node as an OpenObject instance
      def create name, data = OpenObject.new, children = []
        @name = name
        @data = data
        @children = children

        OpenObject.new(:name => @name, :data => @data, :children => @children)
      end
    end
  end
end
