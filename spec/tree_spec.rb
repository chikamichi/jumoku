require 'spec_helper'

describe Tree do
  subject { Tree.new }
  let(:tree) { subject }
  let(:tree_type) { subject.class }
  let(:branch_type) { subject.send :_branch_type }

  it_should_behave_like "a legacy tree"

  it "should be a undirected graph" do
    tree.class.ancestors.should include RawUndirectedTreeBuilder
  end

  it_should_behave_like "a tree with extended features"
end
