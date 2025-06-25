require "test_helper"

class BetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bet = bets(:one)
  end

  test "should get index" do
    get bets_url
    assert_response :success
  end

  test "should get new" do
    get new_bet_url
    assert_response :success
  end

  test "should create bet" do
    assert_difference("Bet.count") do
      post bets_url, params: { bet: { amount: 300.0, color: "green", player_id: players(:two).id, round_id: rounds(:one).id } }
    end

    assert_redirected_to bet_url(Bet.last)
  end

  test "should show bet" do
    get bet_url(@bet)
    assert_response :success
  end

  test "should get edit" do
    get edit_bet_url(@bet)
    assert_response :success
  end

  test "should update bet" do
    patch bet_url(@bet), params: { bet: { amount: @bet.amount, color: @bet.color, player_id: @bet.player_id, round_id: @bet.round_id } }
    assert_redirected_to bet_url(@bet)
  end

  test "should destroy bet" do
    assert_difference("Bet.count", -1) do
      delete bet_url(@bet)
    end

    assert_redirected_to bets_url
  end
end
