require File.join(File.dirname(__FILE__), 'spec_helper')

# The RawTree builder implements TreeAPI and ensures the tree
# is a valid tree as far as Graph Theory is concerned:
# a tree is an undirected, connected, acyclic graph. 
#
# Note: these tests may make use of the "root"/"children" terminology.
# Be aware this has got *no* structural meaning as a tree is, by
# definition, undirected. Those terms are used only to simplify
# nodes creation within the tests, so I recall who branched who.
# For tests about rooted tree, see arborescence_spec.rb
describe "RawTreeBuilder" do
  before :each do
    #class MyTree
      #include RawTreeBuilder
    #end

    @tree = RawTree.new
  end

  describe "#new" do
    it "should create a valid tree graph" do
      @tree.should_not be_directed
      @tree.should be_acyclic
      @tree.should be_connected
      # aka @tree.should be_valid, 'll use that from now own

      @tree.nodes.should be_empty
    end
  end

  # Testing TreeAPI implementation.

  describe "#add_node!" do
    describe "an empty tree" do
      it "should grow up as a valid tree when adding its first node" do
        @tree.nodes.size.should == 0
        
        @tree.add_node! "root"
        @tree.nodes.size.should == 1
        @tree.nodes.should == ["root"]
      end
    end

    describe "a tree with only one node" do
      before :each do
        @tree.add_node! "root" # remember, this has no meaning
      end

      it "should raise an error when trying to add a new (disconnected) node" do
        lambda { @tree.add_node! "child1" }.should raise_error
      end

      it "should grow up as a valid tree when adding new (connected) nodes" do
        lambda { @tree.add_node! "child1", "root" }.should_not raise_error

        @tree.add_node! "child2", "root"
        @tree.add_node! "grand-child1", "child2"
        @tree.add_node! Evergreen::Branch.new("grand-child2", "child2")

        @tree.nodes.size.should == 5
        
        the_nodes = ["root", "child1", "child2", "grand-child1", "grand-child2"]
        @tree.nodes.should == the_nodes
        @tree.topsort.should_not == the_nodes

        @tree.add_node! "grand-grand-child1", "grand-child1"
        @tree.add_node! "child3", "root"
        @tree.add_node! "grand-child3", "child3"
        @tree.add_node! "grand-grand-grand-child", "grand-grand-child1"
        @tree.should_not be_directed
        @tree.should be_acyclic
        @tree.should be_connected
      end

      it "should raise an error when trying to form a cycle" do
        @tree.add_node! "child1", "root"
        @tree.add_node! "child2", "root"
        @tree.add_node! "grand-child", "child1"

        lambda { @tree.add_node! "grand-child", "child2" }.should raise_error RawTreeError

        @tree.add_node! "grand-grand-child", "grand-child"
        lambda { @tree.add_node! "grand-grand-child", "child1" }.should raise_error RawTreeError
        lambda { @tree.add_node! "grand-grand-child", "child2" }.should raise_error RawTreeError
      end
    end
  end

  describe "#add_branch!" do
    describe "an empty tree" do
      it "should allow for the creation of its first two nodes as a branch" do
        lambda { @tree.add_branch! :first, :branch }.should_not raise_error
        @tree.nodes.should == [:first, :branch]
        @tree.should be_valid
      end
    end

    describe "a tree that's not empty" do
      before :each do
        @tree.add_node! 1
      end

      it "should not allow for disconnected branch creation" do
        lambda { @tree.add_branch! 10, 11 }.should raise_error RawTreeError
      end
      
      it "should grow up as a valid tree when populated with (connected) branches" do
        @tree.nodes.size.should == 1

        @tree.add_branch! 1, 2
        @tree.nodes.should_not be_empty
        @tree.nodes.size.should == 2
        @tree.nodes.should == [1, 2]

        @tree.add_branch! 2, 3
        @tree.nodes.size.should == 3
        @tree.nodes.should == [1, 2, 3]

        @tree.add_branch! 3, 4
        @tree.add_branch! 2, 5
        lambda { @tree.add_branch! 5, 5 }.should raise_error RawTreeError # cycle (loop)
        @tree.add_branch! 4, 3
        @tree.add_branch! 5, 6
        @tree.nodes.size.should == 6
        @tree.nodes.should == [1, 2, 3, 4, 5, 6]
        @tree.should be_valid
      end
    end
  end
 
  describe "#remove_node!" do
    describe "an empty tree" do
      it "should not allow to remove a node since there's none" do
        lambda { @tree.remove_node! "vapornode" }.should raise_error RawTreeError
      end
    end

    describe "a tree that's a single node" do
      before :each do
        @tree.add_node! :last
      end

      it "should allow for last node deletion" do
        lambda { @tree.remove_node! :last }.should_not raise_error
        @tree.nodes.should be_empty
        @tree.should be_valid
      end
    end

    describe "a tree that is one sole branch (two nodes)" do
      before :each do
        @tree1 = RawTree.new
        @tree1.add_node! 1
        @tree1.add_node! 2, 1
        @tree2 = RawTree.new
        @tree2.add_node! 1
        @tree2.add_node! 2, 1
      end

      it "should allow to remove both nodes in any order" do
        @tree1.remove_node! 1
        @tree1.should be_valid
        @tree1.nodes.should == [2]
        @tree1.should be_valid
        
        @tree2.remove_node! 2
        @tree2.should be_valid
        @tree2.nodes.should == [1]
        @tree2.should be_valid
      end
    end

    describe "a tree with more than two nodes" do
      before :each do
        # TODO: DRY this snippet
        # i stands for internal, t for terminal
        @tree.add_branch! :i1, :i2
        @tree.add_branch! :i2, :i3
        @tree.add_branch! :i3, :i4
        @tree.add_branch! :i3, :i5
        @tree.add_branch! :i4, :t6
        @tree.add_branch! :i5, :t7
        @tree.add_branch! :i1, :t8
      end

      it "should allow deletion of its terminal nodes but not of its internal nodes" do
        @tree.nodes.size.should == 8
        lambda { @tree.remove_node! :t8 }.should_not raise_error
        @tree.nodes.size.should == 7
        @tree.nodes.should_not include :t8
        lambda { @tree.remove_node! :i3 }.should raise_error RawTreeError
        @tree.should be_valid
      end

      it "should remain a valid tree after any terminal node was removed" do
        @tree.remove_node! :t6
        @tree.has_branch?(:i4, :t6).should_not be_true
        @tree.should be_valid
      end
    end
  end

  describe "#remove_branch!" do
    describe "an empty tree" do
      it "should not allow for branch deletion" do
        lambda { @tree.remove_branch! :null, :none }.should raise_error RawTreeError
      end
    end
    
    describe "an tree that is only one node" do
      before :each do
        @tree.add_node! 1
      end

      it "should not allow for branch deletion" do
        lambda { @tree.remove_branch! 1, :none }.should raise_error RawTreeError
      end
    end
    
    describe "a tree with more than two nodes" do
      before :each do
        # TODO: DRY this snippet
        # i stands for internal, t for terminal
        @tree.add_branch! :i1, :i2
        @tree.add_branch! :i2, :i3
        @tree.add_branch! :i3, :i4
        @tree.add_branch! :i3, :i5
        @tree.add_branch! :i4, :t6
        @tree.add_branch! :i5, :t7
        @tree.add_branch! :i1, :t8
      end

      it "should allow for terminal branch deletion (triggers terminal node deletion)" do
        @tree.nodes.size.should == 8
        lambda { @tree.remove_branch! :i1, :i2 }.should raise_error RawTreeError
        @tree.nodes.size.should == 8
        lambda { @tree.remove_branch! :i1, :t8 }.should_not raise_error RawTreeError
        @tree.nodes.should_not include :t8
        @tree.has_branch?(:i1, :t8).should be_false
        @tree.should be_valid

        @tree.remove_branch! Branch.new(:i5, :t7)
        @tree.has_branch?(:i5, :t7).should be_false
        @tree.should be_valid
      end
    end
  end

  describe "#nodes" do
    describe "an empty tree" do
      it "should not have any node" do
        @tree.nodes.should be_empty
      end
    end

    describe "a tree with some node" do
      it "should be aware of its node(s)" do
        @tree.add_node! :solo
        @tree.nodes.should == [:solo]
        
        @tree.add_branch! 2, :solo
        @tree.add_branch! 2, 3
        @tree.nodes.should == [:solo, 2, 3]
        @tree.should be_valid
      end
    end
  end

  describe "#terminal_nodes" do
    describe "an empty tree" do
      it "should have no terminal nodes" do
        @tree.terminal_nodes.should be_empty
      end
    end

    describe "a tree that's a single node" do
      it "should have one terminal node" do
        @tree.add_node! 1
        @tree.terminal_nodes.should == [1]
      end
    end

    describe "a populated tree" do
      before :each do
        @tree.add_node! 1
        @tree.add_node! 2, 1
        @tree.add_node! 3, 2
      end

      it "should have a least two terminal nodes" do
        @tree.terminal_nodes.size.should >= 2

        @tree.add_node! 4, 3
        @tree.add_node! 5, 3
        @tree.terminal_nodes.should == [1, 4, 5]
      end
    end
  end

  describe "#branches" do
    describe "an empty tree" do
      it "should not have any branch" do
        @tree.branches.should be_empty
      end
    end

    describe "a tree that's one node" do
      it "should not have any branch" do
        @tree.add_node! :solo
        @tree.branches.should be_empty
      end
    end

    describe "a tree that's one branch (two nodes)" do
      it "should have one branch only (undirected)" do
        @tree.add_node! :one
        @tree.add_node! :two, :one
        @tree.branches.size.should == 1
        @tree.branches.first.class.should == Graphy::Edge # the Evergreen::Branch class is just
                                                          # a lazy wrapper of it
        @tree.should be_valid
      end
    end

    describe "a tree with n nodes" do
      before :each do
        # TODO: DRY this as random_tree(n = 10)
        @n = rand(50) # number of nodes
        @tree.add_node! @n
        @old_node = @n

        (@n - 1).times do
          begin
            @new_node = rand(100)
            @tree.add_node!(@new_node, @old_node)
          rescue RawTreeError
            retry # cycle detected!
          end
          @old_node = @new_node
        end
      end

      it "should have n - 1 branches" do
        @tree.nodes.size.should == @n
        @tree.branches.size.should == @n - 1
        @tree.should be_valid
      end
    end
  end

  # TODO: add a final test which sums it up
end
