require 'spec_helper'

shared_examples_for "a legacy tree" do
  describe "#new" do
    it "should create a valid tree graph" do
      tree.should be_valid
      tree.nodes.should be_empty
    end
  end

  describe "#add_node!" do
    describe "an empty tree" do
      it "should grow up as a valid tree when adding its first node" do
        tree.nodes.size.should == 0

        tree.add_node! 1 # adding a raw string as the first node
        tree.nodes.size.should == 1
        tree.nodes.should == [1]
      end
    end

    describe "a tree with only one node" do
      before :each do
        tree.add_node! 1
      end

      it "should raise an error when trying to add a new, disconnected node" do
        # again, I'll use childX for the sake of this specs, as it is easy to
        # remember, but the node is not really a "child" of the previous node,
        # it is just connected
        lambda { tree.add_node! 2 }.should raise_error
      end

      it "should grow up as a valid tree when adding new, connected nodes" do
        lambda { tree.add_node! 2, 1 }.should_not raise_error

        tree.add_node! 3, 1
        tree.add_node! 1, 4
        tree.add_node! branch_type.new(3, 5)

        tree.should be_valid
        tree.nodes.size.should == 5
        tree.nodes.sort.should == [1,2,3,4,5]
      end

      it "should raise an error when trying to form a cycle" do
        tree.add_node! 2, 1
        tree.add_node! 3, 1
        tree.add_node! 4, 2

        lambda { tree.add_node! 4, 1 }.should raise_error ForbiddenCycle
      end
    end
  end

  describe "#add_branch!" do
    describe "an empty tree" do
      it "should create a branch and return the updated tree" do
        tree.add_branch!(:one, :two).should be_a tree_type
        tree.should be_valid
        tree.nodes.should == [:one, :two]
      end
    end

    describe "a tree containing a single node" do
      before :each do
        tree.add_node! 1
      end

      it "should not allow disconnected branch creation" do
        lambda { tree.add_branch! 10, 11 }.should raise_error RawTreeError
      end

      it "should grow up as a valid tree when populated with connected branches" do
        tree.nodes.size.should == 1

        tree.add_branch! 1, 2
        tree.nodes.should_not be_empty
        tree.nodes.size.should == 2
        tree.nodes.sort.should == [1, 2]

        tree.add_branch! 2, 3
        tree.nodes.size.should == 3
        tree.nodes.sort.should == [1, 2, 3]

        tree.add_branch! 3, 4
        tree.add_branch! 2, 5
        lambda { tree.add_branch! 5, 5 }.should raise_error ForbiddenCycle
        lambda { tree.add_branch! 1, 5 }.should raise_error ForbiddenCycle
        tree.add_branch! 5, 6
        tree.nodes.size.should == 6
        tree.nodes.sort.should == [1, 2, 3, 4, 5, 6]
        tree.should be_valid
      end
    end
  end

  describe "#remove_node!" do
    describe "an empty tree" do
      it "should not allow to remove a node since there's none" do
        lambda { tree.remove_node! "undefinedNode" }.should raise_error UndefinedNode
      end
    end

    describe "a tree containing a single node" do
      before :each do
        tree.add_node! :last
      end

      it "should allow for last node deletion" do
        lambda { tree.remove_node! :last }.should_not raise_error
        tree.nodes.should be_empty
        tree.should be_valid
      end
    end

    describe "a tree containing one branch" do
      before :each do
        tree.add_node! 1
        tree.add_node! 2, 1
      end

      it "should allow to remove both nodes in any order" do
        tree.remove_node! 1
        tree.should be_valid
        tree.nodes.sort.should == [2]
        tree.should be_valid
      end
    end

    describe "a tree containing several branches" do
      before :each do
        # TODO: DRY this snippet
        # i stands for internal, t for terminal
        tree.add_branch! :i1, :i2
        tree.add_branch! :i2, :i3
        tree.add_branch! :i3, :i4
        tree.add_branch! :i3, :i5
        tree.add_branch! :i4, :t6
        tree.add_branch! :i5, :t7
        tree.add_branch! :i1, :t8
      end

      it "should allow deletion of its terminal nodes but not of its internal nodes" do
        tree.nodes.size.should == 8
        lambda { tree.remove_node! :t8 }.should_not raise_error
        tree.nodes.size.should == 7
        tree.nodes.should_not include :t8
        lambda { tree.remove_node! :i3 }.should raise_error UndefinedNode
        tree.should be_valid
      end

      it "should remain a valid tree after any terminal node was removed" do
        tree.remove_node! :t6
        tree.has_branch?(:i4, :t6).should_not be_true
        tree.should be_valid
      end
    end
  end

  describe "#remove_branch!" do
    describe "an empty tree" do
      it "should not allow for branch deletion" do
        lambda { tree.remove_branch! :null, :none }.should raise_error RawTreeError
      end
    end

    describe "an tree containing one node" do
      before :each do
        tree.add_node! 1
      end

      it "should not allow for branch deletion" do
        lambda { tree.remove_branch! 1, :none }.should raise_error RawTreeError
      end
    end

    describe "a tree containing several branches" do
      before :each do
        # TODO: DRY this snippet
        # i stands for internal, t for terminal
        tree.add_branch! :i1, :i2
        tree.add_branch! :i2, :i3
        tree.add_branch! :i3, :i4
        tree.add_branch! :i3, :i5
        tree.add_branch! :i4, :t6
        tree.add_branch! :i5, :t7
        tree.add_branch! :i1, :t8
      end

      it "should allow for terminal branch deletion (triggers terminal node deletion)" do
        tree.nodes.size.should == 8
        lambda { tree.remove_branch! :i1, :i2 }.should raise_error RawTreeError
        tree.nodes.size.should == 8
        lambda { tree.remove_branch! :i1, :t8 }.should_not raise_error RawTreeError
        tree.nodes.should_not include :t8
        tree.has_branch?(:i1, :t8).should be_false
        tree.should be_valid

        tree.remove_branch! branch_type.new(:i5, :t7)
        tree.has_branch?(:i5, :t7).should be_false
        tree.should be_valid
      end
    end
  end

  describe "#nodes" do
    describe "an empty tree" do
      it "should not have any node" do
        tree.nodes.should be_empty
      end
    end

    describe "a tree containing several nodes" do
      it "should be aware of its nodes" do
        tree.add_node! :solo
        tree.nodes.should == [:solo]

        tree.add_branch! 2, :solo
        tree.add_branch! 2, 3
        tree.nodes.should == [:solo, 2, 3]
        tree.should be_valid
      end
    end
  end

  describe "#terminal_nodes" do
    describe "an empty tree" do
      it "should have no terminal nodes" do
        tree.terminal_nodes.should be_empty
      end
    end

    describe "a tree containing one node" do
      it "should have one terminal node" do
        tree.add_node! 1
        tree.terminal_nodes.should == [1]
      end
    end

    describe "a tree with several branches" do
      before :each do
        tree.add_node! 1
        tree.add_node! 2, 1
        tree.add_node! 3, 2
      end

      it "should have a least two terminal nodes" do
        tree.terminal_nodes.size.should >= 2

        tree.add_node! 4, 3
        tree.add_node! 5, 3
        tree.terminal_nodes.sort.should == [1, 4, 5]
      end
    end
  end

  describe "#branches" do
    describe "an empty tree" do
      it "should not have any branch" do
        tree.branches.should be_empty
      end
    end

    describe "a tree containing one node" do
      it "should not have any branch" do
        tree.add_node! :solo
        tree.branches.should be_empty
      end
    end

    describe "a tree containing one branch" do
      it "should have one branch only" do
        tree.add_node! :one
        tree.add_node! :two, :one
        tree.branches.size.should == 1
        tree.should be_valid
      end
    end
  end
end
