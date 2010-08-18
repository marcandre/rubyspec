# encoding: utf-8

require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

# Note: this describes the generic #size and #size=
# Specialized #size methods are found in subfolders, e.g. loop/size_spec.rb

ruby_version_is "1.9.3" do
  describe "Enumerator#size" do
    before :each do
      @e = Enumerator.new{|y| y << :foo << :bar}
    end

    describe "when called without a block" do
      it "returns nil when size was not specified" do
        @e.size.should == nil
      end

      it "returns the specified size" do
        @e.size = 42
        @e.size.should == 42
      end

      it "returns the result of the given size block or method" do
        values = [42, 1, 2, 3]
        @e.size = Proc.new{ values.pop }
        @e.size.should == 3
        @e.size.should == 2
        def values.shift(x)
          super()
        end
        @e.size = values.method(:shift)
        @e.size.should == 42
        @e.size.should == 1
      end

      it "yields the receiver and the arguments to the given size block or method" do
        values = [42, 1, 2, 3]
        def values.foo(*args)
          each{|x| yield x}
        end
        s = "hello"
        @e = values.to_enum(:foo, s)
        receiver = nil
        arg = nil
        @e.size = lambda{|r, a| receiver = r; arg = a; r.size }
        @e.size.should == 4
        receiver.should equal(values)
        arg.should equal(s)
      end

      it "is lazy and doesn't iterate" do
        lambda{
          Enumerator.new{ raise "be lazy!" }.size
        }.should_not raise_error
      end
    end

    describe "when called with a block" do
      it "returns the actual size when size was not specified" do
        @e.size{}.should == 2
      end

      it "ignores the specified size" do
        @e.size = 42
        @e.size{}.should == 2
      end

      it "ignores the given size block or method" do
        @e.size = Proc.new{ raise "ignore me" }
        lambda{
          @e.size{}
        }.should_not raise_error
      end
    end
  end

  describe "Array#permutation.size" do
    it "returns the number of permutations" do
      [].permutation.size.should == 1
      [1].permutation.size.should == 1
      [1, 2].permutation(3).size.should == 0
      (1..5).to_a.permutation(2).size.should == 20
      (1..100).to_a.permutation.size.should == 93326215443944152681699238856266700490715968264381621468592963895217599993229915608941463976156518286253697920827223758251185210916864000000000000000000000000
    end
  end

  describe "Array#combination.size" do
    it "returns the number of combinations" do
      [].combination(0).size.should == 1
      [1].combination(0).size.should == 1
      [1].combination(1).size.should == 1
      [1, 2].combination(3).size.should == 0
      (1..5).to_a.combination(2).size.should == 10
      (1..5).to_a.combination(3).size.should == 10
      (1..100).to_a.combination(40).size.should == 13746234145802811501267369720
    end
  end

  describe "Array#repeated_permutation.size" do
    it "returns the number of repeated permutations" do
      [ ].repeated_permutation(0).size.should == 1
      [ ].repeated_permutation(2).size.should == 0
      [1].repeated_permutation(0).size.should == 1
      [1].repeated_permutation(5).size.should == 1
      [1].repeated_permutation(-1).size.should == 0
      (1..100).to_a.repeated_permutation(40).size.should == 100**40
    end
  end

  describe "Array#repeated_combination.size" do
    it "returns the number of repeated combinations" do
      [ ].repeated_combination(0).size.should == 1
      [ ].repeated_combination(2).size.should == 0
      [1].repeated_combination(0).size.should == 1
      [1].repeated_combination(5).size.should == 1
      [1].repeated_combination(-1).size.should == 0
      (1..5).to_a.repeated_combination(3).size.should == 35
      (1..100).to_a.repeated_combination(40).size.should == 126279609474586092455213621207360700
    end
  end

  describe "Array#cycle.size" do
    it "returns the size" do
      [ ].cycle.size.should == 0
      [1].cycle.size.should == Float::INFINITY
      [1,2].cycle(3).size.should == 6
    end
  end

  describe "Kernel#loop.size" do
    it "returns Infinity" do
      loop.size.should == Float::INFINITY
    end
  end

  describe "Enumerator#size when created from an enumerable" do
    before :each do
      @methods = [:each_with_index, :each_entry, :reverse_each,
                  :find_all, :reject, :map, :flat_map, :partition, :group_by, :sort_by,
                  :min_by, :max_by, :minmax_by ]
    end

    it "returns nil if the Enumerable has no size method" do
      e = EnumeratorSpecs::Numerous.new
      @methods.each do |method|
        e.send(method).size.should == nil
      end
      e.each_with_object(:foo).size.should == nil
    end

    it "uses the size method if there is one" do
      e = EnumeratorSpecs::SizedNumerous.new
      @methods.each do |method|
        e.send(method).size.should == 6
      end
      e.each_with_object(:foo).size.should == 6
    end
  end

  describe "Enumerable#each_slize.size" do
    it "returns the right size" do
      e = EnumeratorSpecs::SizedNumerous.new(*1..42)
      e.each_slice(3).size.should == 14
      e.each_slice(4).size.should == 11
    end
  end

  describe "Enumerable#each_cons.size" do
    it "returns the right size" do
      e = EnumeratorSpecs::SizedNumerous.new(*1..42)
      e.each_cons(3).size.should == 40
      e.each_cons(50).size.should == 0
    end
  end

  describe "Enumerable#cycle.size" do
    it "returns the right size" do
      e = EnumeratorSpecs::SizedNumerous.new
      e.cycle(3).size.should == 18
      e.cycle(0).size.should == 0
      e.cycle(-1).size.should == 0
      e.cycle.size.should == Float::INFINITY
    end
  end

  describe "Enumerator#size when created from a Hash" do
    it "returns the hash's size" do
      h = {"hello" => "world", :foo => :bar, 1 => 2}
      [ :each, :each_value, :each_key, :each_pair,
        :keep_if, :delete_if, :reject!, :select, :select!
      ].each do |method|
        h.send(method).size.should == 3
      end
    end
  end

  describe "Enumerator#size when created from ENV" do
    it "returns the number of environment variables" do
      s = ENV.to_a.size
      [ :each, :each_value, :each_key, :each_pair,
        :keep_if, :delete_if, :reject!, :select, :select!
      ].each do |method|
        ENV.send(method).size.should == s
      end
    end
  end

  describe "Enumerator#size when created from a Struct" do
    it "returns the number of fields" do
      klass = Struct.new(:foo, :bar, :baz)
      s = klass.new
      [ :each, :each_pair, :select
      ].each do |method|
        s.send(method).size.should == 3
      end
    end
  end

  describe "Numeric#step.size" do
    it "returns the right size for fixnums" do
      42.step(99, 3).size.should == 20
      42.step(100, 3).size.should == 20
      42.step(20, 3).size.should == 0
      42.step(20, -3).size.should == 8
      10.step(20).size.should == 11
    end

    it "returns the right size for floats" do
      0.5.step(4.2, 0.3).size.should == 13
      0.5.step(4.2, -0.3).size.should == 0
      -0.5.step(-4.2, -0.3).size.should == 13
    end

    it "returns the right size for bignums" do
      (2 ** 100).step(2 ** 100 + 42, 2).size.should == 22
      (2 ** 100).step(2 ** 100 - 41, 2).size.should == 0
      (2 ** 100).step(2 ** 100 - 41, -2).size.should == 21
    end
  end

  describe "Numeric#upto.size" do
    it "returns the right size for fixnums" do
      42.upto(99).size.should == 58
      42.upto(20).size.should == 0
    end

    it "returns the right size for bignum arguments" do
      (2 ** 100).upto(2 ** 100 + 42).size.should == 43
      (2 ** 100).upto(2 ** 100 - 42).size.should == 0
    end
  end

  describe "Numeric#downto.size" do
    it "returns the right size for fixnums" do
      42.downto(99).size.should == 0
      42.downto(20).size.should == 23
    end

    it "returns the right size for bignum arguments" do
      (2 ** 100).downto(2 ** 100 + 42).size.should == 0
      (2 ** 100).downto(2 ** 100 - 42).size.should == 43
    end
  end

  describe "Numeric#times.size" do
    it "returns the right size" do
      5.times.size.should == 5
      (2 ** 99).times.size.should == 2 ** 99
    end

    it "returns 0 for negative integers" do
      (-5).times.size.should == 0
      (-2 ** 99).times.size.should == 0
    end
  end

  describe "String#each_byte.size" do
    it "returns the size" do
      "Môntréål".each_byte.size.should == 11
    end
  end

  describe "String#each_char.size" do
    it "returns the number of characters" do
      "Môntréål".each_char.size.should == 8
    end
  end

  describe "String#each_codepoint.size" do
    it "returns the number of characters" do
      "Môntréål".each_codepoint.size.should == 8
    end
  end
end
