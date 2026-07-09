# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Schemas::Coercers::JSONToArray do
  subject(:coercer) { described_class }

  let :attributes do
    {windows: %([{"days": ["monday"], "start": "08:00", "end": "18:00"}])}
  end

  let :result do
    Dry::Schema::Result.new attributes, message_compiler: proc { Hash.new }, result_ast: []
  end

  describe "#call" do
    it "answers array with symbolized keys when key and value are present" do
      expect(coercer.call(:windows, result)).to eq(
        windows: [{days: ["monday"], start: "08:00", end: "18:00"}]
      )
    end

    it "answers original array when value is an array" do
      attributes[:windows] = [{days: ["monday"], start: "08:00", end: "18:00"}]

      expect(coercer.call(:windows, result)).to eq(
        windows: [{days: ["monday"], start: "08:00", end: "18:00"}]
      )
    end

    it "answers nil when key is present and value is nil" do
      attributes[:windows] = nil
      expect(coercer.call(:windows, result)).to eq(windows: nil)
    end

    it "answers empty string when key is present and value is blank" do
      attributes[:windows] = ""
      expect(coercer.call(:windows, result)).to eq(windows: "")
    end

    it "answers empty hash when key is missing" do
      attributes.clear
      expect(coercer.call(:windows, result)).to eq({})
    end

    it "answers empty hash when result has nil value" do
      result = Dry::Schema::Result.new(nil, message_compiler: proc { Hash.new }, result_ast: [])
      expect(coercer.call(:windows, result)).to eq({})
    end
  end
end
