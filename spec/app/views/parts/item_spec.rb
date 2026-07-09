# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Parts::Item do
  subject :part do
    described_class.new value: Factory.structs[:playlist_item, windows:], rendering:
  end

  let(:rendering) { Terminus::View.new.rendering }
  let(:windows) { [{"days" => %w[monday], "start" => "08:00", "end" => "18:00"}] }

  describe "#coverage" do
    it "answers labels for each day of week" do
      expect(part.coverage.map(&:first)).to eq(%w[S M T W T F S])
    end

    it "answers hourly cells for each day of week" do
      expect(part.coverage.map { |_, cells| cells.size }).to eq([24, 24, 24, 24, 24, 24, 24])
    end

    it "answers covered hours for scheduled day" do
      expect(part.coverage[1].last[8..17]).to all(be(true))
    end

    it "answers uncovered hours for scheduled day" do
      expect(part.coverage[1].last.values_at(7, 18)).to eq([false, false])
    end

    it "answers uncovered hours for unscheduled day" do
      expect(part.coverage[2].last).to all(be(false))
    end

    it "answers no coverage when windows are empty" do
      part = described_class.new(value: Factory.structs[:playlist_item, windows: []], rendering:)

      expect(part.coverage.flat_map(&:last)).to all(be(false))
    end
  end
end
