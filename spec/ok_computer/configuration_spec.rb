describe OkComputer do
  let(:username) { "foo" }
  let(:password) { "bar" }
  let(:whitelist) { [:default] }
  let(:bogus) { "asdfasdfasdfas" }

  context "#require_authentication" do
    it "captures username and password necessary to access OkComputer" do
      OkComputer.require_authentication(username, password)
      OkComputer.send(:username).should == username
      OkComputer.send(:password).should == password
      OkComputer.send(:whitelist).should be_empty
    end

    it "captures an optional list of whitelisted actions to skip authentication" do
      OkComputer.require_authentication(username, password, except: whitelist)
      OkComputer.send(:whitelist).should == whitelist
    end
  end

  context "#requires_authentication?" do
    context "with a configured username and password" do
      before do
        OkComputer.send(:username=, username)
        OkComputer.send(:password=, password)
      end

      context "without a whitelist" do
        before do
          OkComputer.stub(:options) { {} }
        end

        it "is true" do
          OkComputer.requires_authentication?.should be_truthy
        end
      end

      context "with a whitelist" do
        let(:action) { "default" }
        before do
          OkComputer.send(:options=, {except: [action]})
        end

        it "is true for the #index action" do
          OkComputer.requires_authentication?({action: "index"}).should be_truthy
        end

        it "is true for #show if params[:check] is not whitelisted" do
          OkComputer.requires_authentication?({action: "show", check: "somethingelse"}).should be_truthy
        end

        it "is false for #show if params[:check] is whitelisted" do
          OkComputer.requires_authentication?({action: "show", check: action}).should_not be_truthy
        end
      end
    end

    context "without a configured username and password" do
      before do
        OkComputer.send(:username=, nil)
        OkComputer.send(:password=, nil)
        OkComputer.send(:options=, {})
      end

      it "is false" do
        OkComputer.requires_authentication?.should be_falsey
      end
    end
  end

  context "#authenticate(username, password)" do
    it "returns true if OkComputer is not set up to require authentication" do
      OkComputer.require_authentication(nil, nil)
      OkComputer.authenticate(bogus, bogus).should be_truthy
    end

    context "when set up to require authentication" do
      before do
        OkComputer.require_authentication(username, password)
      end

      it "returns true if given the correct username and password" do
        OkComputer.authenticate(username, password).should be_truthy
      end

      it "returns false if not given the correct username and password" do
        OkComputer.authenticate(bogus, bogus).should be_falsey
      end
    end
  end

  context "#mount_at" do
    it "has default mount_at value of 'okcomputer'" do
      OkComputer.mount_at.should == 'okcomputer'
    end

    it "allows configuration of mount_at" do
      OkComputer.respond_to?('mount_at=').should be_truthy
    end
  end

  context "#analytics_ignore" do
    it "has default mount_at value of true" do
      OkComputer.analytics_ignore.should == true
    end

    it "allows configuration of analytics_ignore" do
      OkComputer.respond_to?('analytics_ignore=').should be_truthy
    end
  end
end
