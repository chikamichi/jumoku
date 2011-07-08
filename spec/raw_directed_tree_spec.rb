require 'spec_helper'

describe RawDirectedTree do
  subject { RawDirectedTree.new }
  let(:tree) { subject }
  let(:tree_type) { subject.class }
  let(:branch_type) { subject.send :_branch_type }

  it_should_behave_like "a legacy tree"
  it "should not allow to add a reverse arc" do
    tree.add_branch! 1, 2
    lambda { tree.add_branch! 2, 1 }.should raise_error ForbiddenCycle
  end
end
