require 'spec_helper'
require 'core_tree_behavior'

describe RawDirectedTree do
  subject { RawDirectedTree.new }

  it_should_behave_like "a legacy tree" do
    let(:tree) { subject }
    let(:tree_type) { subject.class }
    let(:branch_type) { subject.send :_branch_type }
  end

  it "should not allow to add a reverse arc" do
    subject.add_branch! 1, 2
    lambda { subject.add_branch! 2, 1 }.should raise_error ForbiddenCycle
  end
end
