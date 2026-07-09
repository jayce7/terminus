# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::PlaylistItem, :db do
  subject(:repository) { described_class.new }

  let(:playlist_item) { Factory[:playlist_item] }

  describe "#all" do
    it "answers all records by created date/time" do
      playlist_item
      expect(repository.all.map(&:id)).to contain_exactly(playlist_item.id)
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#create_with_position" do
    let(:playlist) { Factory[:playlist] }
    let(:screen) { Factory[:screen] }

    it "answers item with position" do
      repository.create_with_position playlist_id: playlist.id, screen_id: screen.id
      item = repository.create_with_position playlist_id: playlist.id, screen_id: screen.id

      expect(item).to have_attributes(
        playlist_id: playlist.id,
        screen_id: screen.id,
        position: 2,
        playlist: kind_of(Terminus::Structs::Playlist),
        screen: kind_of(Terminus::Structs::Screen)
      )
    end

    it "answers position scoped to playlist" do
      other = Factory[:playlist]
      repository.create_with_position playlist_id: other.id, screen_id: screen.id
      item = repository.create_with_position playlist_id: playlist.id, screen_id: screen.id

      expect(item.position).to eq(1)
    end

    it "answers next position after an item is deleted" do
      first = repository.create_with_position playlist_id: playlist.id, screen_id: screen.id
      repository.create_with_position playlist_id: playlist.id, screen_id: screen.id
      repository.delete first.id
      item = repository.create_with_position playlist_id: playlist.id, screen_id: screen.id

      expect(item.position).to eq(3)
    end
  end

  describe "#delete_all" do
    it "deletes records with specific attributes" do
      playlist_item
      Factory[:playlist_item, repeat_type: "minute"]
      repository.delete_all repeat_type: "minute"

      expect(repository.all).to contain_exactly(playlist_item)
    end

    it "answers number of records deleted" do
      playlist_item
      expect(repository.delete_all).to eq(1)
    end

    it "answers zero when there is nothing to delete" do
      expect(repository.delete_all).to eq(0)
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(playlist_item.id)).to eq(playlist_item)
    end

    it "answers nil for unknown ID" do
      expect(repository.find(666)).to be(nil)
    end

    it "answers nil for nil ID" do
      expect(repository.find(nil)).to be(nil)
    end
  end

  describe "#find_by" do
    it "answers record when found by single attribute" do
      expect(repository.find_by(playlist_id: playlist_item.playlist_id)).to eq(playlist_item)
    end

    it "answers record when found by multiple attributes" do
      result = repository.find_by playlist_id: playlist_item.playlist_id,
                                  screen_id: playlist_item.screen_id

      expect(result).to eq(playlist_item)
    end

    it "answers nil when not found" do
      expect(repository.find_by(playlist_id: 666)).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(playlist_id: nil)).to be(nil)
    end
  end

  describe "#next_item" do
    let(:playlist_id) { Factory[:playlist].id }
    let(:noon) { Time.new 2025, 1, 1, 12, 0 }
    let(:window) { {"days" => %w[wednesday], "start" => "08:00", "end" => "18:00"} }

    it "answers next item" do
      one = Factory[:playlist_item, playlist_id:, position: 1]
      two = Factory[:playlist_item, playlist_id:, position: 2]

      expect(repository.next_item(after: one.position, playlist_id:)).to have_attributes(
        position: two.position,
        screen: kind_of(Terminus::Structs::Screen)
      )
    end

    it "answers first item when after last position" do
      one = Factory[:playlist_item, playlist_id:, position: 1]
      Factory[:playlist_item, playlist_id:, position: 2]

      expect(repository.next_item(after: 2, playlist_id:)).to have_attributes(
        position: one.position
      )
    end

    it "answers same item when playlist has only one item" do
      item = Factory[:playlist_item, playlist_id:, position: 1]

      expect(repository.next_item(after: item.position, playlist_id:)).to have_attributes(
        position: item.position
      )
    end

    it "answers next item with gaps after" do
      Factory[:playlist_item, playlist_id:, position: 3]
      expect(repository.next_item(after: 1, playlist_id:)).to have_attributes(position: 3)
    end

    it "answers next item with gaps before" do
      Factory[:playlist_item, playlist_id:, position: 1]
      expect(repository.next_item(after: 3, playlist_id:)).to have_attributes(position: 1)
    end

    it "skips item outside display window" do
      one = Factory[:playlist_item, playlist_id:, position: 1, windows: [window]]
      Factory[:playlist_item, playlist_id:, position: 2, windows: []]
      three = Factory[:playlist_item, playlist_id:, position: 3, windows: [window]]

      expect(repository.next_item(after: one.position, playlist_id:, at: noon)).to have_attributes(
        position: three.position
      )
    end

    it "wraps to first item within display window" do
      one = Factory[:playlist_item, playlist_id:, position: 1, windows: [window]]
      two = Factory[:playlist_item, playlist_id:, position: 2, windows: [window]]
      Factory[:playlist_item, playlist_id:, position: 3, windows: []]

      expect(repository.next_item(after: two.position, playlist_id:, at: noon)).to have_attributes(
        position: one.position
      )
    end

    it "answers nil when no item is within display window" do
      Factory[:playlist_item, playlist_id:, position: 1, windows: []]
      expect(repository.next_item(after: 1, playlist_id:, at: noon)).to be(nil)
    end
  end

  describe "#where" do
    it "answers record for single attribute" do
      result = repository.where playlist_id: playlist_item.playlist_id
      expect(result).to contain_exactly(playlist_item)
    end

    it "answers record for multiple attributes" do
      result = repository.where playlist_id: playlist_item.playlist_id,
                                screen_id: playlist_item.screen_id

      expect(result).to contain_exactly(playlist_item)
    end

    it "answers empty array for unknown value" do
      expect(repository.where(playlist_id: 666)).to eq([])
    end

    it "answers empty array for nil" do
      expect(repository.where(playlist_id: nil)).to eq([])
    end
  end
end
