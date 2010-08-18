require File.expand_path('../../../spec_helper', __FILE__)

ruby_version_is "1.9" do
  describe "Kernel#to_enum" do
    it "needs to be reviewed for spec completeness"

    ruby_version_is "1.9.3" do
      it "accepts a size block" do
        x = "foo"
        args = nil
        enum = x.to_enum(:foo, :bar){|*a| args = a; 42}
        enum.size.should == 42
        args.should == [x, :bar]
      end
    end
  end
end
