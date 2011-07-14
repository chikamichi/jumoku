require 'spec_helper'

describe Arborescence do
  subject { Arborescence.new }
  let(:tree) { subject }
  let(:tree_type) { subject.class }
  let(:branch_type) { subject.send :_branch_type }

  it_should_behave_like "a legacy tree"

  it "should be a directed graph" do
    tree.class.ancestors.should include RawDirectedTreeBuilder
  end

  it_should_behave_like "a tree with extended features"

  context "arcs flow" do
    it "should by default be forced to match direction of the first arc added" do
      tree.add_branch! 1, 2, 0
      tree.add_branch! 2, 3, 1
      tree.add_branch! 4, 3, 2 # will be reversed actually
      tree.edges.sort_by { |edge| edge.label }.map { |edge| edge.target }.should == [2, 3, 4]
    end

    it "should be possible to relax this constraint" do
      tree = Arborescence.new(:free_flow => true)
      tree.add_branch! 1, 2, 0
      tree.add_branch! 2, 3, 1
      tree.add_branch! 4, 3, 2 # will *not* be reversed
      tree.edges.sort_by { |edge| edge.label }.map { |edge| edge.target }.should == [2, 3, 3]
    end
  end

  context "root helpers" do
    before :each do
      tree.add_branches! 1,2, 2,3, 1,4, 4,5, 4,6
    end

    describe "#root" do
      it "should return the root node" do
        tree.root.should == 1
      end
    end

    describe "#root_edges" do
      it "should return the edge(s) branched from the root" do
        tree.root_edges.size.should == 2
      end
    end

    describe "#root?" do
      it "should report whether a node is the root" do
        tree.root?(1).should be_true
        (3..6).all? { |i| !tree.root?(i) }.should be_true
      end
    end
  end

  context "offsprings helpers" do
    before :each do
      tree.add_branches! 1,2, 2,3, 1,4, 4,5, 4,6
    end

    describe "#offsprings" do
      it "should return the list of offsprings nodes for a node" do
        tree.offsprings(1).sort.should == [2,4]
        tree.offsprings_of(4).sort.should == [5,6]
      end
    end
  end

  describe "parent helpers" do
    before :each do
      tree.add_branches! 1,2, 2,3, 1,4, 4,5, 4,6
    end

    describe "#parent" do
      it "should return the parent of a node" do
        tree.parent(1).should be_nil
        tree.parent(2).should == 1
        tree.parent_of(6).should == 4
      end
    end

    describe "parent?" do
      it "should check whether a node is the parent of another (which may be specified)" do
        tree.parent?(1).should be_true
        tree.parent?(6).should be_false
        tree.parent?(1,2).should be_true
      end
    end
  end

  context "siblings helpers" do
    before :each do
      tree.add_branches! 1,2, 2,3, 1,4, 4,5, 4,6, 1,7
    end

    describe "#siblings" do
      it "should return the siblings for a node" do
        tree.siblings(1).should be_empty
        tree.siblings_of(2).sort.should == [4,7]
      end
    end

    describe "#siblings?" do
      it "should check whether two nodes are siblings" do
        tree.siblings?(1,2).should be_false
        tree.siblings?(2,3).should be_false
        tree.siblings?(2,4).should be_true
      end
    end

    describe "#neighbours" do
      before :each do
        tree.add_node! 2, 8
        tree.add_node! 7, 9
      end

      it "should return the grand-siblings for a node" do
        tree.neighbours(1).should be_empty
        tree.neighbours(2).size.should == 2
        [4,7].each { |node| tree.neighbours(2).should include([node]) }
        neighbours  = tree.neighbours(8)
        neighbours.size.should == 2
        neighbours.should include [5,6]
        neighbours.should include [9]
      end

      it "should be able to include siblings as well" do
        neighbours = tree.neighbours(8, :siblings => true)
        neighbours.size.should == 3
        neighbours.should include [3]
        neighbours.should include [5,6]
        neighbours.should include [9]
      end
    end

    describe "#neighbours?" do
      before :each do
        tree.add_node! 2, 8
        tree.add_node! 7, 9
      end

      it "should check whether two nodes are neighbours" do
        tree.neighbours?(1,2).should be_false
        tree.neighbours?(2,8).should be_false
        tree.neighbours?(3,8).should be_false
        tree.neighbours?(5,8).should be_true
      end

      it "should be possible to include siblings in the match" do
        tree.neighbours?(3,8, :siblings => true).should be_true
      end
    end
  end

  context "leaf nodes inspection" do
    before :each do
      tree.add_branches! 1,2, 2,3, 1,4, 1,5
    end

    describe "#leaves" do
      it "should list the leaf nodes" do
        tree.leaves.sort.should == [3,4,5]
      end
    end

    describe "#leaf?" do
      it "should check whether a node is a leaf" do
        tree.leaf?(1).should be_false
        tree.leaf?(2).should be_false
        tree.leaf?(3).should be_true
        tree.leaf?(4).should be_true
        tree.leaf?(5).should be_true
      end
    end

    describe "#leaves?" do
      it "should check whether each node of a list is a leaf" do
        tree.leaves?(1).should be_false
        tree.leaves?(1,2).should be_false
        tree.leaves?(1,2,3).should be_false
        tree.leaves?(3,4).should be_true
        tree.leaves?(3,4,5).should be_true
      end
    end
  end
end
