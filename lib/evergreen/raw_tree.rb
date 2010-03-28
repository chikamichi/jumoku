module Evergreen
  module RawTree
    extend self
    include Node

    attr_accessor :id
    attr_accessor :name
    attr_accessor :data
    attr_accessor :parent

    # Create a new raw tree.
    # 
    # @param [#to_sym] name the name of the root node initializing the tree
    #
    # @option *options [Symbol] :names_as nodes identification method: as a string
    #   (`name` must respond to `to_s`), as a symbolized string (`name` must respond
    #   to `to_sym`) or as a unique random id (base64 strings, 10 characters long).
    #   With `:strings` and `:symbols` values, nodes names must be unique.
    # @option *options [Object] :data the data field type to use. Defaults to an empty OpenObject,
    #   for the root and each tree nodes (can be overriden on a per-node basis as well).
    #
    # @raise [ArgumentError] if the no name is provided
    # @raise [ArgumentError] if the provided name is not valid given the specified `:names_as` option
    # @raise [ArgumentError] if invalid any options value is supplied
    #
    # @return [Evergreen::RawTree] the root node of the raw tree
    def initialize name, *options
      raise ArgumentError, "a name must be provided for the root node (may be nil)" if name.nil?

      options.extract_options!
             .reverse_merge! :names_as => :strings, :data_as => OpenObject.new

      # create the root node/leaf
      # FIXME: should be a call to insert_new_node(name, parent(TreeNode)=nil, [children(*TreeNode)], [content=OpenObject.new])
      # which in turns would call
      # node = Node.create(name, [content]),
      # self.attach_child(node, parent=nil),
      # self.children.each { |child| node.attach_child(child) }
      #
      # Donc module Evergreen::RawTree::Node avec ses helpers : new, attach_child
      # attention, si attach_child reçoit parent=nil, il y a deux cas de figures :
      # - si @nodes.empty? alors un nouvel arbre est créé, avec le node comme root ;
      # - si !@nodes.empty? (donc il y a une racine), alors une nouvelle "branche morte"
      #   de l'arbre est créée (il y a un store @dead_branches qui liste les racines des
      #   branches mortes de l'arbre courant).
      id = generate_new_id

      case options[:names_as]
      when :strings
        raise ArgumentError unless name.respond_to? :to_s
        name = name.to_s
      when :symbols
        raise ArgumentError unless name.respond_to? :to_sym
        name = name.to_sym
      when :ids
        name = id
      else
        raise ArgumentError, ":names should match either :strings, :symbols or :ids"
      end

      data = options[:data_as]
      children = []

      root_node = Node.create(name, data, children)
      @nodes[self.id] = root_node
      setAsRoot! # parent= nil

      # create the tree metadata stores
      @nodes = OpenObject.new

      # add the root node in the stores
      @nodes[self.id] = self

      if block_given?
        # you may write tree = Evergreen::RawTree.new "my tree" { |data, children| # work with the default data }
        yield @nodes[self.id].data, @nodes[self.id].children
      end

      return @nodes[self.id]
    end

    def parent= parent
      @parent = parent
    end

    def new_child child
      raise ArgumentError, "Children already added" if options[:unique_child] and @children.inc
    end

    def generate_new_id
      id = nil

      while(id.nil? or not @nodes[id].nil?) do
        id = SecureRandom.base64(10)
      end

      return id
    end
  end
end
