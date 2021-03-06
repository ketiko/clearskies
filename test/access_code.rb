require 'minitest/autorun'

require_relative '../lib/access_code'

describe AccessCode, "generating" do
  it "should start with SYNC" do
    AccessCode.create.to_s.must_match /\ASYNC/
  end

  it "should be 33 characters" do
    AccessCode.create.to_s.size.must_equal 33
  end

  it "should parse back to itself" do
    16.times do
      str = AccessCode.create.to_s
      code = AccessCode.parse str
      code.to_s.must_equal str
    end
  end

  it "should be unique" do
    codes = {}
    100.times do
      code = AccessCode.create.to_s
      codes.has_key?(code).must_equal false
      codes[code] = true
    end
  end

  it "should allow clearskies: protocol" do
    str = AccessCode.create.to_s
    code = AccessCode.parse "clearskies:#{str}"
    code.to_s.must_equal str
  end
end
