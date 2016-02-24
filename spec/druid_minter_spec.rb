require 'spec_helper'

describe PreAssembly::DruidMinter do

  before(:all) do
    @minter = PreAssembly::DruidMinter
  end

  it "should get a sequence of druids from calls to next()" do
    exp = @minter.current
    3.times { expect(@minter.next).to eq(exp.next!) }
  end

  it "should return unique string objects" do
    o1 = @minter.next
    o2 = @minter.next
    expect(o1.object_id).not_to eq(o2.object_id)
  end

end
