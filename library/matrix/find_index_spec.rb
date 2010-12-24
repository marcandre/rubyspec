require File.expand_path('../../../spec_helper', __FILE__)
require 'matrix'

ruby_version_is "1.9.3" do
  describe "Matrix#find_index" do
    before :all do
      @m = Matrix[ [1, 2, 3, 4], [5, 6, 7, 8] ]
    end

    it "returns an Enumerator when called without a block" do
      enum = @m.find_index
      enum.should be_an_instance_of(enumerator_class)
      enum.to_a.should == [1, 2, 3, 4, 5, 6, 7, 8]
    end

    it "returns nil if the block is always false" do
      @m.find_index{false}.should be_nil
    end

    it "returns the first index for which the block is true" do
      @m.find_index{|x| x >= 3}.should == [0, 2]
    end
  end

  describe "Matrix#find_index with an argument" do
    before :all do
      @m = Matrix[ [1, 2, 3, 4], [5, 6, 7, 8] ]
      @t = Matrix[ [1, 2], [3, 4], [5, 6], [7, 8] ]
    end

    it "raises an ArgumentError for unrecognized argument" do
      lambda {
        @m.find_index("all"){}
      }.should raise_error(ArgumentError)
      lambda {
        @m.find_index(nil){}
      }.should raise_error(ArgumentError)
      lambda {
        @m.find_index(:left){}
      }.should raise_error(ArgumentError)
    end

    it "yields the rights elements when passed :diagonal" do
      @m.find_index(:diagonal).to_a.should == [1, 6]
      @t.find_index(:diagonal).to_a.should == [1, 4]
    end

    it "yields the rights elements when passed :lower" do
      @m.find_index(:lower).to_a.should == [1, 5, 6]
      @t.find_index(:lower).to_a.should == [1, 3, 4, 5, 6, 7, 8]
    end

    it "yields the rights elements when passed :strict_lower" do
      @m.find_index(:strict_lower).to_a.should == [5]
      @t.find_index(:strict_lower).to_a.should == [3, 5, 6, 7, 8]
    end

    it "yields the rights elements when passed :strict_upper" do
      @m.find_index(:strict_upper).to_a.should == [2, 3, 4, 7, 8]
      @t.find_index(:strict_upper).to_a.should == [2]
    end

    it "yields the rights elements when passed :upper" do
      @m.find_index(:upper).to_a.should == [1, 2, 3, 4, 6, 7, 8]
      @t.find_index(:upper).to_a.should == [1, 2, 4]
    end
  end
end
