require "spec_helper"

module OKComputer
  describe Registry do
    let(:check_object) { double(:checker, :registrant_name= => nil) }

    context ".registry" do
      let(:some_hash) { double(:hash) }

      around(:each) do |example|
        existing = Registry.instance_variable_get(:@registry)
        example.run
        Registry.instance_variable_set(:@registry, existing)
      end

      it "keeps the hash of the registered checks keyed on their names" do
        Registry.instance_variable_set(:@registry, some_hash)
        Registry.registry.should == some_hash
      end

      it "defaults to an empty hash if not set" do
        Registry.instance_variable_set(:@registry, nil)
        Registry.registry.should == {}
      end
    end

    context ".all" do
      let(:registry) { {foo: "bar"} }
      let(:collection) { double(:check_collection) }

      before do
        Registry.stub(registry: registry)
      end
      it "returns a CheckCollection with all of the registered checks" do
        CheckCollection.should_receive(:new).with(registry) { collection }
        Registry.all.should == collection
      end
    end
    context ".fetch(check_name)" do
      let(:check_name) { "foo" }

      it "returns the check registered with the given name" do
        Registry.register(check_name, check_object)
        Registry.fetch(check_name).should == check_object
      end

      it "raises an exceiption if given a check that's not registered" do
        Registry.deregister(check_name)
        expect { Registry.fetch(check_name) }.to raise_error(Registry::CheckNotFound)
      end
    end

    context ".register(check_name, check_object)" do
      let(:check_name) { "foo" }
      let(:second_check_object) { double(:checker, :registrant_name= => nil) }

      before do
        # make sure it isn't there yet
        Registry.deregister(check_name)
      end

      it "assigns the given name to the checker" do
        check_object.should_receive(:registrant_name=).with(check_name)
        Registry.register(check_name, check_object)
      end

      it "adds the checker to the list of checkers" do
        Registry.register(check_name, check_object)
        Registry.registry[check_name].should == check_object
      end

      it "overwrites the current check with the given name" do
        # put the first one in and make sure it's there
        Registry.register(check_name, check_object)
        Registry.registry[check_name].should == check_object

        # put the second one in there, and first one gets replaced
        Registry.register(check_name, second_check_object)
        Registry.registry.values.should_not include check_object
        Registry.registry[check_name].should == second_check_object
      end
    end

    context ".deregister(check_name)" do
      let(:check_name) { "foo" }

      it "removes the checker from the list of checkers" do
        # add it
        Registry.register(check_name, check_object)
        # then remove it
        Registry.deregister(check_name)
        Registry.registry.keys.should_not include check_name
        Registry.registry.values.should_not include check_object
      end

      it "does not error if the name isn't registered" do
        Registry.deregister(check_name)
        Registry.deregister(check_name)
      end
    end
  end
end

