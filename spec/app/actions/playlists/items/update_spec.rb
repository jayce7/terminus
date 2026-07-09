# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::Playlists::Items::Update, :db do
  subject(:action) { described_class.new }

  describe "#call" do
    let(:item) { Factory[:playlist_item] }
    let(:repository) { Terminus::Repositories::PlaylistItem.new }

    let :params do
      {
        id: item.id,
        playlist_id: item.playlist_id,
        playlist_item: {
          screen_id: item.screen_id,
          windows: %([{"days": ["monday"], "start": "08:00", "end": "18:00"}])
        }
      }
    end

    it "updates item display windows" do
      Rack::MockRequest.new(action).put("", params:)

      expect(repository.find(item.id).windows).to eq(
        [{"days" => ["monday"], "start" => "08:00", "end" => "18:00"}]
      )
    end

    it "answers unprocessable entity with invalid windows" do
      params[:playlist_item][:windows] = "bogus"
      response = Rack::MockRequest.new(action).put("", params:)

      expect(response.status).to eq(422)
    end

    it "answers unprocessable entity with invalid parameters" do
      params.delete :playlist_item
      response = Rack::MockRequest.new(action).put("", params:)

      expect(response.status).to eq(422)
    end
  end
end
