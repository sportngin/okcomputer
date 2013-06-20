require "spec_helper"

describe OKComputer do
  let(:username) { "foo" }
  let(:password) { "bar" }
  let(:whitelist) { [:default] }
  let(:bogus) { "asdfasdfasdfas" }

  context "#require_authentication" do
    it "captures username and password necessary to access OKComputer" do
      OKComputer.require_authentication(username, password)
      OKComputer.send(:username).should == username
      OKComputer.send(:password).should == password
      OKComputer.send(:whitelist).should be_empty
    end

    it "captures an optional list of whitelisted actions to skip authentication" do
      OKComputer.require_authentication(username, password, except: whitelist)
      OKComputer.send(:whitelist).should == whitelist
    end
  end

  context "#requires_authentication?" do
    context "with a configured username and password" do
      before do
        OKComputer.send(:username=, username)
        OKComputer.send(:password=, password)
      end

      context "without a whitelist" do
        before do
          OKComputer.send(:options=, {})
        end

        it "is true" do
          OKComputer.requires_authentication?.should be_true
        end
      end

      context "with a whitelist" do
        let(:action) { "default" }
        before do
          OKComputer.send(:options=, {except: [action]})
        end

        it "is true for the #index action" do
          OKComputer.requires_authentication?({action: "index"}).should be_true
        end

        it "is true for #show if params[:check] is not whitelisted" do
          OKComputer.requires_authentication?({action: "show", check: "somethingelse"}).should be_true
        end

        it "is false for #show if params[:check] is whitelisted" do
          OKComputer.requires_authentication?({action: "show", check: action}).should_not be_true
        end
      end
    end

    context "without a configured username and password" do
      before do
        OKComputer.send(:username=, nil)
        OKComputer.send(:password=, nil)
        OKComputer.send(:options=, {})
      end

      it "is false" do
        OKComputer.requires_authentication?.should be_false
      end
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
