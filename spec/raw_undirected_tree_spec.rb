require 'spec_helper'

describe RawUndirectedTree do
  subject { RawUndirectedTree.new }
  let(:tree) { subject }
  let(:tree_type) { subject.class }
  let(:branch_type) { subject.send :_branch_type }

  it_should_behave_like "a legacy tree"
  it "should allow to 'add' a reverse edge (that is, silently ignored)" do
    tree.add_branch! 1, 2
    lambda { tree.add_branch! 2, 1 }.should_not raise_error
  end
end
