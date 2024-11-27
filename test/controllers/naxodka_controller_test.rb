require "test_helper"

class NaxodkaControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get naxodka_index_url
    assert_response :success
  end
end
