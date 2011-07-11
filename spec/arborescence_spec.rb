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

  context "root helpers" do
    before :each do
      tree.add_branches! 1,2, 2,3, 1,4, 4,5, 4,6
    end

    it "#root should return the root node" do
      tree.root.should == 1
    end

    it "#root_edge(s) should return the edge(s) branched from the root" do
      tree.root_edges.size.should == 2
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
