require File.join(File.dirname(__FILE__), 'spec_helper')

# The Tree builder extends the core functionalities provided
# by RawTreeBuilder. 
#
# Note: these tests may make use of the "root"/"children" terminology.
# Be aware this has got *no* structural meaning as a tree is, by
# definition, undirected. Those terms are used only to simplify
# nodes creation within the tests, so I recall who branched who.
# For tests about rooted tree, see arborescence_spec.rb
describe "TreeBuilder" do
  before :each do
    class MyTree
      include TreeBuilder
    end

    @tree = MyTree.new
  end

  describe "#new" do
    it "should create a valid tree graph" do
      @tree.should be_valid
      @tree.nodes.should be_empty
    end
  end

  ## Core API is tested in raw_tree_spec.rb.
  ## The following tests focus on TreeBuilder additional methods.

  describe "#add_node" do
    describe "an empty tree" do
      it "should create a new, valid tree with a single node when its first node is added" do
        @tree.add_node 1
        @tree.should be_empty

        new_tree = @tree.add_node 1
        new_tree.nodes.should == [1]
        new_tree.should be_valid
      end
    end

    describe "a populated tree" do
      before :each do
        @tree.add_branch! 1, 2
        @tree.add_branch! 2, 3
        @tree.add_branch! 3, 4
      end

      it "should create a new, extended, valid tree when an additionnal node is added" do
        @tree.add_node 5, 4
        @tree.add_node 3, 6
        @tree.nodes.size.should == 4
        
        new_tree = @tree.add_node 5, 4
        new_tree.nodes.size.should == @tree.nodes.size + 1
        new_tree.nodes.should == [1, 2, 3, 4, 5]
        new_tree.should be_valid
      end
    end
  end

  describe "#add_branch" do
    describe "an empty tree" do
      it "should create a new, valid tree with only two nodes when a branch is added" do
        new_tree = @tree.add_branch :one, :two
        @tree.should be_empty
        @tree.should be_valid
        new_tree.nodes.should == [:one, :two]
        new_tree.should be_valid
      end
    end

    describe "a populate" do
      before :each do
        @tree.add_branch! 1, 2
        @tree.add_branch! 2, 3
        @tree.add_branch! 3, 4
      end

      it "should create a new, extended, valid tree when a branch is added" do
        @tree.add_branch 5, 4
        @tree.add_branch 3, 6
        @tree.nodes.size.should == 4

        new_tree = @tree.add_branch 5, 4
        new_tree.nodes.size.should == @tree.nodes.size + 1
        new_tree.nodes.should == [1, 2, 3, 4, 5]
        new_tree.should be_valid
      end
    end
  end

  describe "#remove_node" do
    describe "an empty tree" do
      it "should raise an error when trying to remove a node" do
        lambda { @tree.remove_node :null }.should raise_error, RawTreeError
      end
    end

    describe "a tree that's one node only" do
      before :each do
        @tree.add_node! 1
      end

      it "should create a new, empty, valid tree" do
        new_tree = @tree.remove_node 1
        @tree.nodes.should == [1]
        @tree.should be_valid
        new_tree.should be_empty
        new_tree.should be_valid
      end
    end
  end

  describe "#remove_branch" do
    describe "an empty tree" do
      it "should not allow for removing a branch (even if forced to)" do
        lambda { @tree.remove_branch 1, 2 }.should raise_error, RawTreeError
        lambda { @tree.remove_branch 1, 2, :force => true }.should raise_error, RawTreeError
      end
    end

    describe "a tree that's one node" do
      before :each do
        @tree.add_node! 1
      end

      it "should not allow for removing a branch (even if forced to)" do
        lambda { @tree.remove_branch 1, 2 }.should raise_error, RawTreeError
        lambda { @tree.remove_branch 1, 2, :force => true }.should raise_error, RawTreeError
      end
    end

    describe "a tree with at least two nodes" do
      before :each do
        @tree.add_branch! 1, 2
        @tree.add_branch! 2, 3
      end

      it "should allow for removing a branch, creating a new, valid tree" do
        lambda { @tree.remove_branch 1, 2, :force => true }.should_not raise_error
        new_tree = @tree.remove_branch 1, 2, :force => true
        @tree.nodes.should == [1, 2, 3]
        new_tree.nodes.should == [2, 3]
        new_tree.should be_valid
      end
    end
  end

  describe "#add_nodes!" do
    describe "an empty tree" do
      it "should allow for adding its first nodes, by pairs and branches" do
        @tree.add_nodes! 1,2, 2,3, 3,4
        @tree.nodes.should == [1, 2, 3, 4]
        @tree.should be_valid

        @tree.add_nodes! Branch.new(5, 2)
        @tree.nodes.should == [1, 2, 3, 4, 5]
        @tree.should be_valid

        @tree.add_nodes! 3,4, 1,10, Branch.new(10, 11), -1,1
        @tree.nodes.size.should == 8
        @tree.should be_valid

        lambda { @tree.add_nodes! 10, 11 }.should_not raise_error
        lambda { @tree.add_nodes! 1,  11 }.should     raise_error, RawTreeError # cycle

        @tree = Tree.new
        lambda { @tree.add_nodes! 1,2, 3,4 }.should      raise_error, RawTreeError # not connected
        lambda { @tree.add_nodes! 1,2, 2,3, 3,1 }.should raise_error, RawTreeError # cycle
        lambda { @tree.add_nodes! 1, 2, 3 }.should       raise_error, RawTreeError # even number of nodes
      end
    end
  end

  describe "#add_nodes" do
    describe "an empty tree" do
      it "should allow for adding its first nodes, by pairs and branches, creating a new, valid tree" do
        new_tree = @tree.add_nodes 1,2, 2,3, 3,4
        @tree.should be_empty
        new_tree.nodes.should == [1, 2, 3, 4]
        new_tree.should be_valid
        
        new_tree = @tree.add_nodes Branch.new(4, 5)
        @tree.should be_empty
        new_tree.nodes.should == [4, 5]
        new_tree.should be_valid

        new_tree = @tree.add_nodes 3,4, 4,10, Branch.new(10, 11), -1,3
        @tree.should be_empty
        new_tree.nodes.size.should == 5
        new_tree.should be_valid

        lambda { @tree.add_nodes 10, 11 }.should_not raise_error

        @tree = Tree.new
        lambda { @tree.add_nodes 1,2, 3,4 }.should      raise_error, RawTreeError # not connected
        lambda { @tree.add_nodes 1,2, 2,3, 3,1 }.should raise_error, RawTreeError # cycle
        lambda { @tree.add_nodes 1, 2, 3 }.should       raise_error, RawTreeError # even number of nodes
      end
    end
  end

  describe "#add_branches!" do
    describe "an empty tree" do
      it "should allow for adding its first branches" do
        @tree.add_branches! Branch.new(1, 2), 1,3, 3,4
        @tree.nodes.should == [1, 2, 3, 4]
        @tree.should be_valid

        branch = Branch.new(1, 4)
        lambda { @tree.add_branches! branch }.should raise_error, RawTreeError
      end
    end

    describe "a populated tree" do
      before :each do
        @tree.add_nodes! 1, 2
      end

      it "should allow for adding new branches" do
        @tree.add_branches! 2, 3
        @tree.nodes.should == [1, 2, 3]
        @tree.should be_valid

        @tree.add_branches! Branch.new(0,1), 3,4, Branch.new(4,5)
        [0..5].all? { |n| @tree.nodes.include? n } and @tree.nodes.size.should == 5
        @tree.should be_valid

        lambda { @tree.add_branches! Branch.new(2, 5) }.should raise_error, RawTreeError
      end
    end
  end

  describe "add_branches" do
    describe "an empty tree" do
      it "should create a new, valid tree populated with its first branches" do
        b1, b2, b3 = Branch.new(1, 2), Branch.new(2, 3), Branch.new(3, 4)
        new_tree = @tree.add_branches b1, b2, b3
        @tree.should be_empty
        new_tree.nodes.should == [1, 2, 3, 4]
        new_tree.should be_valid

        lambda { @tree.add_branches 1,2, 2,3, 3,1 }.should raise_error, RawTreeError
      end
    end

    describe "a populated tree" do
      before :each do
        @tree.add_nodes! 1,2, 2,3, 3,4
      end

      it "should create a new, valid tree extended with its new branches" do
        new_tree = @tree.add_branches 4, :five, Branch.new(:five, "six")
        @tree.nodes.should == (1..4).to_a
        new_tree.nodes.should == [1, 2, 3, 4, :five, "six"]
        new_tree.should be_valid

        lambda { @tree.add_branches 10, 11 }.should   raise_error, RawTreeError
        lambda { @tree.add_branches Branch.new 1,4 }.should     raise_error, RawTreeError
      end
    end
  end

  describe "#remove_nodes!" do
    describe "an empty tree" do
      it "should not allow for removing nodes" do
        lambda { @tree.remove_nodes! :foo, :bar }.should raise_error, RawTreeError
      end
    end

    describe "a tree that's one node" do
      before :each do
        @tree.add_node! :one
      end

      it "should allow for removing its sole node only (bad semantic)" do
        @tree.remove_nodes! :one
        @tree.nodes.should be_empty
        @tree.should be_valid

        lambda { @tree.remove_nodes! :foo, :bar }.should raise_error, RawTreeError
      end
    end

    describe "a populated tree" do
      before :each do
        @tree.add_nodes! 1,2, 2,3, 3,4
      end

      it "should allow for removing its nodes until it's empty" do
        @tree.remove_nodes! (1..4).to_a
        @tree.should be_empty
        @tree.should be_valid

        lambda { @tree.remove_nodes! :null }.should raise_error, RawTreeError
      end
    end
  end

  describe "#remove_nodes" do
    describe "an empty tree" do
      it "should not allow for removing nodes" do
        lambda { @tree.remove_nodes :foo, :bar }.should raise_error, RawTreeError
      end
    end

    describe "a populated tree" do
      before :each do
        @tree.add_nodes! 1,2, 2,3, 3,4
      end

       it "should allow for removing nodes, creating a new, valid tree" do
        new_tree = @tree.remove_nodes 1, 2, 3, 4
        @tree.nodes.should == [1, 2, 3, 4]
        new_tree.should be_empty
        new_tree.should be_valid

        lambda { @tree.remove_nodes! :null }.should raise_error, RawTreeError
       end
    end
  end

  describe "#remove_branches!" do
    describe "an empty tree" do
      it "should not allow for removing branches" do
        lambda { @tree.remove_branches Branch.new(:foo, :bar), 1,2 }.should raise_error, RawTreeError
      end
    end

    describe "a tree that's only one node" do
      before :each do
        @tree.add_node! :solo
      end

      it "should not allow for removing branches" do
        lambda { @tree.remove_branches! :solo, :null }.should raise_error, RawTreeError
      end
    end

    describe "a populated tree" do
     before :each do
        @tree.add_nodes! 1,2, 2,3, 3,4
      end

      it "should allow for removing branches until it has no more branches or a sole node" do
        @tree.remove_branches! 1,2, Branch.new(2,3), 3,4
        @tree.should be_empty
        @tree.should be_valid

        lambda { @tree.remove_branches! Branch.new(:foo, :bar), Branch.new(1, 2) }.should raise_error, RawTreeError
      end
    end
  end
  
  describe "#remove_branches" do
    describe "an empty tree" do
      it "should not allow for removing branches" do
        lambda { @tree.remove_branches :foo, :bar, Branch.new(1, 2) }.should raise_error, RawTreeError
      end
    end

    describe "a tree that's one node" do
      before :each do
        @tree.add_node! :solo
      end

      it "should not allow for removing branches" do
        lambda { @tree.remove_branches :solo, :null }.should raise_error, RawTreeError
      end
    end

    describe "a populated tree" do
     before :each do
        @tree.add_nodes! 1,2, 2,3, 3,4
      end

      it "should allow for removing branches until it has no more branches or a sole node, creating a new, valid tree" do
        new_tree = @tree.remove_branches 1,2, Branch.new(2,3), 3,4
        @tree.nodes.should == [1, 2, 3, 4]
        new_tree.should be_empty
        new_tree.should be_valid

        lambda { @tree.remove_branches Branch.new(:foo, :bar), Branch.new(1, 2) }.should raise_error, RawTreeError
      end
    end
  end

  describe "#node?" do
    describe "an empty tree" do
      it "should not report having any node" do
        @tree.node?(:null).should be_false
      end
    end

    describe "a populated tree" do
     before :each do
        @tree.add_nodes! 1,2, 2,3, 3,4
      end

      it "should be aware of which nodes belong to itself" do
        @tree.node?(1).should be_true
        @tree.has_node?(:null).should be_false
      end
    end
  end

  describe "#nodes?" do
    describe "an empty tree" do
      it "should not report having any node" do
        @tree.nodes?(:null, :foo, 0).should be_false
      end
    end

    describe "a populated tree" do
     before :each do
        @tree.add_nodes! 1,2, 2,3, 3,4
      end

      it "should be aware of which nodes belong to itself" do
        @tree.nodes?(1, 4).should be_true
        @tree.has_nodes?(:null, 1, 2).should be_false
      end
    end
  end
  
  describe "#nodes_among?" do
    describe "an empty tree" do
      it "should not report having any node" do
        @tree.nodes_among?(:null, :foo, 0).should be_false
      end
    end

    describe "a populated tree" do
     before :each do
        @tree.add_nodes! 1,2, 2,3, 3,4
      end

      it "should be aware of which nodes belong to itself" do
        @tree.nodes_among?(1, 4).should be_true
        @tree.has_node_among?(:foo, 2, :bar).should be_true
        @tree.has_nodes_among?(:foo, 2, :bar, 3, 4, Array.new).should be_true
        @tree.has_nodes_among?(:null, :foo, :bar).should be_false
      end
    end
  end

  describe "#branch?" do
    describe "an empty tree" do
      it "should not have any branch" do
        @tree.has_branch?(1,2).should be_false
      end
    end

    describe "a tree that's one node" do
      before :each do
        @tree.add_node! :solo
      end

      it "should not have any branch" do
        @tree.has_branch?(1,2).should be_false
      end
    end
    
    describe "a populated tree" do
     before :each do
        @tree.add_nodes! 1,2, 2,3, 3,4
      end

      it "should be aware of which branches belong to itself" do
        @tree.has_branch?(2,3).should be_true
        @tree.has_branch?(1,3).should be_false
        @tree.has_branch?(1,:null).should be_false
      end
    end
  end

  # TODO: tests for #branches? and #branches_among?
  # (actually, done within the tests for #add_consecutive_nodes!)

  describe "#num_nodes" do
    describe "an empty tree" do
      it "should report having no node" do
        @tree.number_of_nodes.should == 0
      end
    end

    describe "a populated tree" do
     before :each do
        @tree.add_nodes! 1,2, 2,3, 3,4
      end

      it "should report how many nodes belong to it" do
        @tree.number_of_nodes.should == 4
      end
    end
  end
  
  describe "#num_branches" do
    describe "an empty tree" do
      it "should report having no branch" do
        @tree.number_of_nodes.should == 0
      end
    end

    describe "a tree that's one node" do
      before :each do
        @tree.add_node! :solo
      end

      it "should report having no branch" do
        @tree.number_of_branches.should == 0
      end
    end

    describe "a populated tree" do
     before :each do
        @tree.add_nodes! 1,2, 2,3, 3,4
      end

      it "should report how many branches belong to it" do
        @tree.number_of_branches.should == @tree.number_of_nodes - 1
      end
    end
  end

  describe "#add_consecutive_nodes!" do
    describe "a tree" do
      it "should grow as a valid, populated tree if all specified nodes define a valid tree structure" do
        @tree.add_consecutive_nodes!(1, 2, 3, :four, Branch.new(:foo, "bar"))
        @tree.has_branches?(1,2, 2,3, Branch.new(3, :four), :four,:foo, :foo,"bar").should be_true # each specified branch exist
        @tree.has_branches?(1,2, 2,3, Branch.new(3, :four), :four,:foo).should be_true # each specified branch exist
        @tree.has_branches_among?(1,2, 2,3, Branch.new(3, :four), :four,:foo).should be_false # do not list every existing branch
        @tree.has_branches_among?(1,2, 2,3, Branch.new(3, :four), :four,:foo, :foo,"bar").should be_true # list all existing branches
        @tree.has_branches_among?(1,2, 2,3, Branch.new(3, :four), :four,:foo, :foo,"bar", Array.new, "NIL").should be_true # list all existing branches
        @tree.should be_valid
      end
    end
  end
  
  describe "#add_consecutive_nodes" do
    describe "a tree" do
      it "should create a new, valid, populated tree if all specified nodes define a valid tree structure" do
        new_tree = @tree.add_consecutive_nodes(1, 2, 3, :four, Branch.new(:foo, "bar"))
        @tree.should be_empty
        new_tree.has_branches?(1,2, 2,3, Branch.new(3, :four), :four,:foo, :foo,"bar").should be_true
        new_tree.has_branches?(1,2, 2,3, Branch.new(3, :four), :four,:foo).should be_true
        new_tree.should be_valid
      end
    end
  end
end

