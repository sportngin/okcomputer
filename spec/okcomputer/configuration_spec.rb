require "spec_helper"

describe OKComputer do
  let(:username) { "foo" }
  let(:password) { "bar" }
  let(:bogus) { "asdfasdfasdfas" }

  context "#require_authentication" do
    it "captures username and password necessary to access OKComputer" do
      OKComputer.require_authentication(username, password)
      OKComputer.send(:username).should == username
      OKComputer.send(:password).should == password
    end
  end

  context "#requires_authentication?" do
    it "is true if username and password are configured" do
      OKComputer.send(:username=, username)
      OKComputer.send(:password=, password)
      OKComputer.requires_authentication?.should be_true
    end

    it "is false if username and password are not configured" do
      OKComputer.send(:username=, nil)
      OKComputer.send(:password=, nil)
      OKComputer.requires_authentication?.should be_false
    end
  end

  context "#authenticate(username, password)" do
    it "returns true if OKComputer is not set up to require authentication" do
      OKComputer.require_authentication(nil, nil)
      OKComputer.authenticate(bogus, bogus).should be_true
    end

    context "when set up to require authentication" do
      before do
        OKComputer.require_authentication(username, password)
      end

      it "returns true if given the correct username and password" do
        OKComputer.authenticate(username, password).should be_true
      end

      it "returns false if not given the correct username and password" do
        OKComputer.authenticate(bogus, bogus).should be_false
      end
    end
  end
end
