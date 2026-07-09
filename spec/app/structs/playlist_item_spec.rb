# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Structs::PlaylistItem do
  subject :playlist_item do
    Factory.structs[
      :playlist_item,
      screen_id: 1,
      position: 1,
      repeat_interval: 1,
      repeat_type: "none",
      repeat_days: {},
      last_day_of_month: true,
      start_at: at,
      stop_at: at,
      hidden_at: at,
      windows:
    ]
  end

  let(:at) { Time.new 2025, 1, 1 }
  let(:windows) { [{"days" => %w[wednesday], "start" => "08:00", "end" => "18:00"}] }

  describe "#cloneable_attributes" do
    it "answers included attributes only" do
      expect(playlist_item.cloneable_attributes).to eq(
        screen_id: 1,
        position: 1,
        repeat_interval: 1,
        repeat_type: "none",
        repeat_days: {},
        last_day_of_month: true,
        start_at: at,
        stop_at: at,
        hidden_at: at,
        windows:
      )
    end
  end

  describe "#scheduled?" do
    it "answers true when day and time are covered" do
      expect(playlist_item.scheduled?(Time.new(2025, 1, 1, 12, 0))).to be(true)
    end

    it "answers true when time equals start" do
      expect(playlist_item.scheduled?(Time.new(2025, 1, 1, 8, 0))).to be(true)
    end

    it "answers false when time equals end" do
      expect(playlist_item.scheduled?(Time.new(2025, 1, 1, 18, 0))).to be(false)
    end

    it "answers false when day isn't covered" do
      expect(playlist_item.scheduled?(Time.new(2025, 1, 2, 12, 0))).to be(false)
    end

    it "answers false when windows are empty" do
      playlist_item = Factory.structs[:playlist_item, windows: []]
      expect(playlist_item.scheduled?(Time.new(2025, 1, 1, 12, 0))).to be(false)
    end

    it "answers true for any time when start and end are identical" do
      playlist_item = Factory.structs[
        :playlist_item,
        windows: [{"days" => %w[wednesday], "start" => "00:00", "end" => "00:00"}]
      ]

      expect(playlist_item.scheduled?(Time.new(2025, 1, 1, 23, 59))).to be(true)
    end

    context "with window that wraps midnight" do
      let(:windows) { [{"days" => %w[wednesday], "start" => "22:00", "end" => "02:00"}] }

      it "answers true when time is after start" do
        expect(playlist_item.scheduled?(Time.new(2025, 1, 1, 23, 0))).to be(true)
      end

      it "answers true when time is before end" do
        expect(playlist_item.scheduled?(Time.new(2025, 1, 1, 1, 0))).to be(true)
      end

      it "answers false when time is between end and start" do
        expect(playlist_item.scheduled?(Time.new(2025, 1, 1, 12, 0))).to be(false)
      end
    end

    context "with multiple windows" do
      let :windows do
        [
          {"days" => %w[monday], "start" => "08:00", "end" => "12:00"},
          {"days" => %w[wednesday], "start" => "14:00", "end" => "16:00"}
        ]
      end

      it "answers true when any window is covered" do
        expect(playlist_item.scheduled?(Time.new(2025, 1, 1, 15, 0))).to be(true)
      end

      it "answers false when no window is covered" do
        expect(playlist_item.scheduled?(Time.new(2025, 1, 1, 13, 0))).to be(false)
      end
    end
  end
end
