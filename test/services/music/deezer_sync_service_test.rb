require "test_helper"

class Music::DeezerSyncServiceTest < ActiveSupport::TestCase
  setup do
    @service = Music::DeezerSyncService.new("Daft Punk")
  end

  test "successful fetch processes tracks" do
    stub_body = { data: [ { "id" => 1, "title" => "Song", "duration" => 180, "preview" => "http://p", "artist" => { "id" => 10, "name" => "Artist" }, "album" => { "id" => 20, "title" => "Album", "cover_medium" => "http://c" } } ] }.to_json

    stub_request(:get, %r{https://api.deezer.com/search\?q=.*}).to_return(status: 200, body: stub_body)

    result = @service.call
    assert result.success?
    assert_equal 1, result.data.size
  end

  test "handles non-success response" do
    stub_request(:get, %r{https://api.deezer.com/search\?q=.*}).to_return(status: 500, body: "error")

    result = @service.call
    assert_not result.success?
    assert_match /Deezer API returned status 500/, result.errors
  end
end
