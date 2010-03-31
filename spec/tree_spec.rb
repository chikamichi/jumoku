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
        @tree.nodes.should be_empty
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
        new_tree.nodes.should be_empty
        new_tree.should be_valid
      end
    end
  end

  describe "#remove_branch" do
    describe "an empty tree" do
      it "should not allow for removing a branch, even if forced to" do
        lambda { @tree.remove_branch 1, 2 }.should raise_error, RawTreeError
        lambda { @tree.remove_branch 1, 2, :force => true }.should raise_error, RawTreeError
      end
    end

    describe "a tree that's one node, even if forced to" do
      before :each do
        @tree.add_node! 1
      end

      it "should not allow for removing a branch" do
        lambda { @tree.remove_branch 1, 2 }.should raise_error, RawTreeError
        lambda { @tree.remove_branch 1, 2, :force => true }.should raise_error, RawTreeError
      end
    end

    describe "a tree with at least two nodes" do
      before :each do
        @tree.add_branch! 1, 2
        @tree.add_branch! 2, 3
      end

      it "should not allow for removing a branch" do
        lambda { @tree.remove_branch 1, 2 }.should raise_error, RawTreeError,
      end

      it "should allow for removing a branch if forced to, creating a new tree" do
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
        @tree.add_nodes! 1,2, 3,4, 5,6
        @tree.nodes.should == [1, 2, 3, 4, 5, 6]
        @tree.should be_valid
      end
    end
  end
end
