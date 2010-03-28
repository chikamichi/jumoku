module Evergreen
  module RawTree
    extend self

    attr_accessor :name
    attr_accessor :id
    attr_accessor :content
    attr_accessor :parent

    # Create a new raw tree.
    # 
    # @param [#to_sym] name the name of the root node initializing the tree
    # @option *options [Symbol] :names_as nodes identification method: as a string
    #   (`name` must respond to `to_s`), as a symbolized string (`name` must respond
    #   to `to_sym`) or as a unique random id (base64 strings, 10 characters long).
    #   With `:strings` and `:symbols` values, nodes names must be unique.
    # @raise [ArgumentError] if the no name is provided
    # @raise [ArgumentError] if the provided name is not eligible for the `:names_as` option
    # @raise [ArgumentError] if invalid options values are supplied
    # @return [Evergreen::RawTree] the root node of the tree
    def initialize name, *options
      raise ArgumentError, "must provide a name" if name.nil?
      raise ArgumentError unless name.respond_to :to_sym

      options.extract_options!.reverse_merge! :names_as => :strings

      raise ArgumentError, ":names should match either :strings, :symbols or :ids"
        unless [:strings, :symbols, :ids].include? options[:names]

      # create the root node/leaf
      # FIXME: should be a call to insert_new_node(name, parent(TreeNode)=nil, [children(*TreeNode)], [content=OpenObject.new])
      # which in turns would call node = new_node(name, [content]),
      # attach_child(parent node),
      # children.each { |child| node.attach_child(child)
      #
      # Donc module Evergreen::RawTree::Node avec ses helpers : new, attach_child
      # attention, si attach_child reçoit parent=nil, il y a deux cas de figures :
      # - si @nodes.empty? alors un nouvel arbre est créé, avec le node comme root
      # - si !@nodes.empty? (donc il y a une root), alors une nouvelle "branche morte"
      #   pour l'arbre est créée (il y a un store @dead_edges qui liste les racines des
      #   branches mortes pour l'arbre courant).
      @name = name.to_sym
      @id = generate_new_id
      @content = OpenObject.new
      @children = []
      setAsRoot! # parent= nil

      # create the tree metadata stores
      @nodes = OpenObject.new

      # add the root node in the stores
      @nodes[self.id] = self
    end

    def parent= parent
      @parent = parent
    end

    def new_child child
      raise ArgumentError, "Children already added" if options[:unique_child] and @children.inc
    end

    def generate_new_id
      id = nil
      while(id.nil? or @nodes[id]) { SecureRandom.base64(10) }
    end

    module Node

    end
end
