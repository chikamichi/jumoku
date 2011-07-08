require 'spec_helper'
require 'core_tree_behavior'

describe RawUndirectedTree do
  subject { RawUndirectedTree.new }

  it_should_behave_like "a legacy tree" do
    let(:tree) { subject }
    let(:tree_type) { subject.class }
    let(:branch_type) { subject.send :_branch_type }
  end

  it "should allow to 'add' a reverse edge (that is, silently ignored)" do
    subject.add_branch! 1, 2
    lambda { subject.add_branch! 2, 1 }.should_not raise_error
  end
end
