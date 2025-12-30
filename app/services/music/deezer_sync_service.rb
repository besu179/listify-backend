require "net/http"
require "json"

class Music::DeezerSyncService < BaseService
  BASE_URL = "https://api.deezer.com"

  def initialize(query)
    @query = query
  end

  def call
    data = fetch_from_deezer
    return failure("No data found from Deezer") if data["data"].empty?

    processed_items = data["data"].map { |item| process_track(item) }
    success(processed_items)
  rescue StandardError => e
    failure(e.message)
  end

  private

  def fetch_from_deezer
    url = URI("#{BASE_URL}/search?q=#{URI.encode_www_form_component(@query)}")
    response = Net::HTTP.get(url)
    JSON.parse(response)
  end

  def process_track(track_data)
    # Sync Artist
    artist = Artist.find_or_create_by!(deezer_id: track_data["artist"]["id"]) do |a|
      a.name = track_data["artist"]["name"]
    end

    # Sync Album
    album = Album.find_or_create_by!(deezer_id: track_data["album"]["id"]) do |a|
      a.title = track_data["album"]["title"]
      a.cover_url = track_data["album"]["cover_medium"]
      a.artist = artist
    end

    # Sync Song
    song = Song.find_or_create_by!(deezer_id: track_data["id"]) do |s|
      s.title = track_data["title"]
      s.artist_name = artist.name
      s.duration_ms = track_data["duration"] * 1000
      s.preview_url = track_data["preview"]
      s.album = album
      s.artist = artist
    end

    song
  end
end
