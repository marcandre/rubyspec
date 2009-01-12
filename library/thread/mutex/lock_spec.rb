require File.dirname(__FILE__) + '/../../../spec_helper'
require 'thread'

describe "Mutex#lock" do
  it "should return self" do
    m = Mutex.new
    m.lock.should == m
    m.unlock
  end

  it "should wait if the lock is not available" do
    m = Mutex.new

    m.lock
    v = 0

    t1 = Thread.new do
      m.lock
      v = 1
    end

    v.should == 0
    m.unlock
    t1.join
    v.should == 1
  end
end