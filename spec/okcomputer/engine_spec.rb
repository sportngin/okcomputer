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
end
