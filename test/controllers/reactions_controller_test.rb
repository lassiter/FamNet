require 'test_helper'

class ReactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get reactions_index_url
    assert_response :success
  end

  test "should get show" do
    get reactions_show_url
    assert_response :success
  end

  test "should get create" do
    get reactions_create_url
    assert_response :success
  end

  test "should get destroy" do
    get reactions_destroy_url
    assert_response :success
  end

end
