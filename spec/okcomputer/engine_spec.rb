require "spec_helper"

describe OKComputer::Engine do

  context "#prepend_routes" do

    before do
      # clear prepended routes
      Rails.application.routes.instance_variable_set(:@prepend, [])
    end

    it "should mount_the engine at the mount_at option location" do
      OKComputer.stub(:mount_at).and_return('foo')
      OKComputer::Engine.send(:prepend_routes, Rails.application)
      Rails.application.routes.draw { }
      routes = Rails.application.routes.routes.map { |route| route.path.spec.to_s }
      routes.should include '/foo'
    end
  end

  context "#ignore_newrelic" do

    context "#when NewRelic is installed" do
      before do
        stub_const('NewRelic::Agent::Instrumentation::ControllerInstrumentation', Module.new)
      end

      it "should inject newrelic_ignore" do
        OKComputer::OkComputerController.should_receive(:newrelic_ignore).with(no_args())
        OKComputer::Engine.send(:ignore_newrelic)
      end
    end

    context "#when NewRelic is not installed" do
      it "should not inject newrelic_ignore" do
        OKComputer::Engine.should_not_receive(:newrelic_ignore)
        expect{ OKComputer::Engine.send(:ignore_newrelic) }.to_not raise_error
      end
    end
  end
end
