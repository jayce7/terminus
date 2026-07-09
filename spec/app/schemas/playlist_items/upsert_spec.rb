# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Schemas::PlaylistItems::Upsert do
  subject(:schema) { described_class }

  describe "#call" do
    let :attributes do
      {
        screen_id: 1,
        windows: [{days: %w[monday friday], start: "08:00", end: "18:00"}]
      }
    end

    it "answers success when all attributes are valid" do
      expect(schema.call(attributes).to_monad).to be_success
    end

    it "answers success without windows" do
      attributes.delete :windows
      expect(schema.call(attributes).to_monad).to be_success
    end

    it "answers success when windows are empty" do
      attributes[:windows] = []
      expect(schema.call(attributes).to_monad).to be_success
    end

    it "answers success when windows are JSON" do
      attributes[:windows] = %([{"days": ["monday"], "start": "08:00", "end": "18:00"}])
      expect(schema.call(attributes).to_monad).to be_success
    end

    it "answers failure without screen ID" do
      attributes.delete :screen_id
      expect(schema.call(attributes).to_monad).to be_failure
    end

    it "answers failure when windows are invalid JSON" do
      attributes[:windows] = "bogus"
      expect(schema.call(attributes).to_monad).to be_failure
    end

    it "answers failure when day is invalid" do
      attributes[:windows] = [{days: %w[bogus], start: "08:00", end: "18:00"}]
      expect(schema.call(attributes).to_monad).to be_failure
    end

    it "answers failure when days are empty" do
      attributes[:windows] = [{days: [], start: "08:00", end: "18:00"}]
      expect(schema.call(attributes).to_monad).to be_failure
    end

    it "answers failure when start is invalid" do
      attributes[:windows] = [{days: %w[monday], start: "8:00", end: "18:00"}]
      expect(schema.call(attributes).to_monad).to be_failure
    end

    it "answers failure when end is invalid" do
      attributes[:windows] = [{days: %w[monday], start: "08:00", end: "24:00"}]
      expect(schema.call(attributes).to_monad).to be_failure
    end

    it "answers failure when start is missing" do
      attributes[:windows] = [{days: %w[monday], end: "18:00"}]
      expect(schema.call(attributes).to_monad).to be_failure
    end
  end
end
