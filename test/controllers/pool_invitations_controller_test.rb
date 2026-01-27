require "test_helper"

class PoolInvitationsControllerTest < ActionDispatch::IntegrationTest
  include SignInHelper

  setup do
    @private_pool = betting_pools(:private_pool)
    @expired_pool = betting_pools(:expired_pool)
    @regular_user = users(:regular_user)
    @admin_user = users(:admin_user)
  end

  # ============== SHOW TESTS ==============

  test "unauthenticated user is redirected to login" do
    get join_pool_url(@private_pool.invite_code)
    assert_redirected_to login_path
  end

  test "unauthenticated user return URL is preserved" do
    get join_pool_url(@private_pool.invite_code)
    assert_equal join_pool_url(@private_pool.invite_code), session[:return_to_after_authenticating]
  end

  test "authenticated user sees confirmation page" do
    sign_in_as(@regular_user)
    get join_pool_url(@private_pool.invite_code)
    assert_response :success
    assert_select "h2", @private_pool.name
  end

  test "already member is redirected to pool" do
    sign_in_as(@admin_user)
    get join_pool_url(@private_pool.invite_code)
    assert_redirected_to betting_pool_path(@private_pool)
    assert_equal "You're already a member of this pool.", flash[:notice]
  end

  test "invalid invite code redirects to root with error" do
    sign_in_as(@regular_user)
    get join_pool_url("invalid1")
    assert_redirected_to root_path
    assert_equal "Invalid invite link.", flash[:alert]
  end

  test "expired invite code redirects to root with error" do
    sign_in_as(@regular_user)
    get join_pool_url(@expired_pool.invite_code)
    assert_redirected_to root_path
    assert_equal "This invite link has expired.", flash[:alert]
  end

  # ============== ACCEPT TESTS ==============

  test "accept creates membership and redirects to pool" do
    sign_in_as(@regular_user)

    assert_difference -> { @private_pool.betting_pool_memberships.count }, 1 do
      post accept_pool_invitation_url(@private_pool.invite_code)
    end

    assert_redirected_to betting_pool_path(@private_pool)
    assert_equal "Welcome to #{@private_pool.name}!", flash[:notice]
    assert @private_pool.user_in_pool?(@regular_user)
  end

  test "accept by already member redirects without creating duplicate" do
    sign_in_as(@admin_user)

    assert_no_difference -> { @private_pool.betting_pool_memberships.count } do
      post accept_pool_invitation_url(@private_pool.invite_code)
    end

    assert_redirected_to betting_pool_path(@private_pool)
    assert_equal "You're already a member of this pool.", flash[:notice]
  end

  test "accept with invalid code redirects to root" do
    sign_in_as(@regular_user)
    post accept_pool_invitation_url("invalid1")
    assert_redirected_to root_path
    assert_equal "Invalid invite link.", flash[:alert]
  end

  test "accept with expired code redirects to root" do
    sign_in_as(@regular_user)
    post accept_pool_invitation_url(@expired_pool.invite_code)
    assert_redirected_to root_path
    assert_equal "This invite link has expired.", flash[:alert]
  end

  test "unauthenticated accept is redirected to login" do
    post accept_pool_invitation_url(@private_pool.invite_code)
    assert_redirected_to login_path
  end
end
