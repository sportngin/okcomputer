require "spec_helper"

describe OKComputer do
  it "routes the simple check as text by default" do
    {get: "/"}.should route_to({
      controller: "ok_computer",
      action: "show",
      check: "default",
      format: "text",
    })
  end

  it "routes the index check as text by default" do
    {get: "/all"}.should route_to({
      controller: "ok_computer",
      action: "index",
      format: "text",
    })
  end

  it "routes the index check as JSON if requested" do
    {get: "/all.json"}.should route_to({
      controller: "ok_computer",
      action: "index",
      format: "json",
    })
  end

  it "routes a specific check as text by default" do
    {get: "/foo"}.should route_to({
      controller: "ok_computer",
      action: "show",
      check: "foo",
      format: "text",
    })
  end

  it "routes a specific check as JSON if requested" do
    {get: "/foo.json"}.should route_to({
      controller: "ok_computer",
      action: "show",
      check: "foo",
      format: "json",
    })
  end
end
