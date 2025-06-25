require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "should get dashboard" do
    get analytics_dashboard_url
    assert_response :success
  end
end
