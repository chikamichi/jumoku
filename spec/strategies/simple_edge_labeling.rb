require 'spec_helper'

describe Strategies::SimpleEdgeLabeling do
  let(:tree) { Tree.new.use Strategies::SimpleEdgeLabeling }
  let(:arbo) { Arborescence.new.use :simple_edge_labeling }

  describe 'a tree with simple edge labeling' do
    it "should label its edges with increasing integers when new nodes are added or removed" do
      tree.add_node! 1
      tree.add_node! 1, 2 # adding edge 0
      edge = tree.edges.first
      edge.label.should be_an OpenHash
      edge.label._weight.should == 0

      tree.add_branch! 2, 3 # adding edge 1
      tree.edges.all? { |e| e.label.is_a? OpenHash }.should be_true
      tree.edges.map { |e| e.label._weight }.sort.should == [0,1]

      tree.remove_node! 1 # removing edge 0
      tree.add_node! 3, 4 # adding edge 2
      tree.add_node! 2, 5 # adding edge 3
      tree.add_node! 5, 6 # adding edge 4
      tree.remove_node! 6 # removing edge 4
      tree.add_node! 5, 7 # adding edge 5
      tree.edges.map { |e| e.label._weight }.sort.should == [1,2,3,5]
    end

    describe "#sorted_edges" do
      it "should by default return the list of edges in (increasing) order" do
        tree.add_branches! 1,2, 1,3, 2,4, 1,5, 3,6, 1,7
        tree.sorted_edges.map { |e| e.label._weight }.should == (0..5).to_a
      end

      it "should accept a block to sort edges" do
        # for the sake of this specs, one'd actually #reverse the default sorting ;)
        tree.add_branches! 1,2, 1,3, 2,4, 1,5, 3,6, 1,7
        tree.sorted_edges do |edge|
          -edge.label._weight
        end.map { |e| e.label._weight }.should == (0..5).to_a.reverse
      end
    end

    describe "#sort_edges" do
      it "should sort a set of edges using the simple scheme" do
        tree.add_branches! 1,2, 1,3, 2,4, 1,5, 3,6, 1,7
        tree.sort_edges(tree.adjacent(1, :type => :edges)).map { |e| e.target }.should == [2,3,5,7]
      end
    end

    it "should thus allow for local edge and children ordering (directed trees only)" do
      arbo.add_branches! 1,2, 1,3, 2,4, 1,5, 3,6, 1,7
      arbo.sorted_arcs_from(1).map { |e| e.target }.should == [2,3,5,7]
      arbo.sorted_children_of(1).should == [2,3,5,7]
    end

    it "should return nil when asking for nodes ordering on an undirected tree" do
      tree.add_branches! 1,2, 1,3, 2,4, 1,5, 3,6, 1,7
      tree.sorted_arcs_from(1).should == nil
      tree.sorted_children_of(1).should == nil
    end
  end
end
