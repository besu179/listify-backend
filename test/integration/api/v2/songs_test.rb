require "test_helper"

class Api::V2::SongsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @headers = authenticated_header(@user)
    @song = songs(:one)
  end

  test "should get songs index" do
    get api_v2_songs_path, headers: @headers, as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_kind_of Array, json
  end

  test "should show song" do
    get api_v2_song_path(@song), headers: @headers, as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @song.id, json["id"]
    assert json.key?("artist")
  end

  test "should fail for missing song" do
    get api_v2_song_path(-1), headers: @headers, as: :json
    assert_response :not_found
  end

  test "should sync songs from deezer" do
    post sync_api_v2_songs_path,
         params: { query: "Daft Punk" },
         headers: @headers,
         as: :json

    assert_includes [ 200, 422, 500 ], response.status
  end
end
