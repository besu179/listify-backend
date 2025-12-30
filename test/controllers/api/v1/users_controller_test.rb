require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other = users(:two)
    @headers = Devise::JWT::TestHelpers.auth_headers({}, @user)
  end

  test "should get me" do
    get api_v1_users_me_url, headers: @headers, as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal @user.id, body["user"]["id"]
  end

  test "should list following for a user" do
    @user.active_follows.create!(following: @other)

    get following_api_v1_user_url(@user), headers: @headers, as: :json
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal 1, body.count
    assert_equal @other.id, body.first["id"]
  end

  test "should list followers for a user" do
    # other follows user
    @other.active_follows.create!(following: @user)

    get followers_api_v1_user_url(@user), headers: @headers, as: :json
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal 1, body.count
    assert_equal @other.id, body.first["id"]
  end
end
