require File.join(File.dirname(__FILE__), 'spec_helper')

# The Tree builder extends the core functionalities provided
# by RawTreeBuilder. 
#
# Note: these tests may make use of the "root"/"children" terminology.
# Be aware this has got *no* structural meaning as a tree is, by
# definition, undirected. Those terms are used only to simplify
# nodes creation within the tests, so I recall who branched who.
# For tests about rooted tree, see arborescence_spec.rb
describe "TreeBuilder" do
  before :each do
    class MyTree
      include TreeBuilder
    end

    @tree = MyTree.new
  end

  describe "#new" do
    it "should create a valid tree graph" do
      @tree.should be_valid
      @tree.nodes.should be_empty
    end
  end

  ## Core API is tested in raw_tree_spec.rb.
  ## The following tests focus on TreeBuilder additional methods.

  describe "#add_node" do
    describe "an empty tree" do
      it "should create new, valid trees when new nodes are added" do
        @tree.add_node 1
        @tree.should be_empty
      end
    end
  end
end
