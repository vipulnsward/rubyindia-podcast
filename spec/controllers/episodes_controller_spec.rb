require 'spec_helper'

describe EpisodesController do
  describe '#index' do
    it 'renders the response with etag and last_modified' do
      episode = create(:episode)

      # ActiveRecord have cache_key method
      # which use :nsec to find out the last
      # updated_at column, this test was failing
      # because randomly cache_key was different in controller
      episode.reload

      get :index, show_id: episode.show.to_param

      key = ActiveSupport::Cache.expand_cache_key(episode)
      etag = %("#{Digest::MD5.hexdigest(key)}")
      expect(response.headers["ETag"]).to eq etag
      expect(response.headers["Last-Modified"]).to eq episode.updated_at.httpdate
    end
  end

  describe '#index as xml' do
    it 'renders the index template for published episodes' do
      episode = create(:episode)
      get :index, show_id: episode.show.to_param, format: :xml
      expect(response).to render_template("index")
    end

    it 'allows cross origin resources' do
      episode = create(:episode)

      get :index, show_id: episode.show.to_param, format: :xml

      expect(response.headers['Access-Control-Allow-Origin']).to eq '*'
      expect(response.headers['Access-Control-Request-Method']).to eq '*'
    end
  end

  describe '#show a non-published episode' do
    it 'responds with the episode' do
      episode = create(:episode, published_on: 7.days.from_now)

      get :show, show_id: episode.show, id: episode

      expect(response).to be_success
    end
  end

  describe '#show as mp3' do
    it 'increments the download counter and 302 redirects to the mp3' do
      episode = create(:episode, mp3: episode_mp3_fixture)

      expect(episode.downloads_count).to eq 0
      get :show,
        show_id: episode.show.to_param,
        id: episode.to_param,
        format: :mp3
      episode.reload

      expect(episode.downloads_count).to eq 1
      expect(response).to redirect_to(episode.mp3.url(:id3))
      expect(response.code).to eq '302'
    end
  end
end
