# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Contracts::PlaylistItems::Update do
  subject(:contract) { described_class.new }

  describe "#call" do
    let :attributes do
      {
        id: 1,
        playlist_id: 1,
        playlist_item: {
          screen_id: 1,
          windows: [{days: %w[monday], start: "08:00", end: "18:00"}]
        }
      }
    end

    it "answers success when all attributes are valid" do
      expect(contract.call(attributes).to_monad).to be_success
    end

    it "answers failure without ID" do
      attributes.delete :id
      expect(contract.call(attributes).to_monad).to be_failure
    end

    it "answers failure without screen ID" do
      attributes[:playlist_item].delete :screen_id
      expect(contract.call(attributes).to_monad).to be_failure
    end

    it "answers failure when windows are invalid" do
      attributes[:playlist_item][:windows] = [{days: %w[bogus], start: "08:00", end: "18:00"}]
      expect(contract.call(attributes).to_monad).to be_failure
    end
  end
end
