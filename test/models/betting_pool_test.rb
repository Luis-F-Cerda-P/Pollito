require "test_helper"

class BettingPoolTest < ActiveSupport::TestCase
  test "generates invite code on creation" do
    pool = BettingPool.new(
      name: "New Pool",
      event: events(:world_cup),
      creator: users(:admin_user)
    )
    assert_nil pool.invite_code
    pool.save!
    assert_not_nil pool.invite_code
    assert_equal 8, pool.invite_code.length
    assert_match(/\A[a-z0-9]+\z/, pool.invite_code)
  end

  test "invite code is unique" do
    pool1 = BettingPool.create!(
      name: "Pool One",
      event: events(:world_cup),
      creator: users(:admin_user)
    )
    pool2 = BettingPool.create!(
      name: "Pool Two",
      event: events(:world_cup),
      creator: users(:regular_user)
    )
    assert_not_equal pool1.invite_code, pool2.invite_code
  end

  test "invite_expired? returns false for future event" do
    pool = betting_pools(:private_pool)
    assert_not pool.invite_expired?
  end

  test "invite_expired? returns true for past event" do
    pool = betting_pools(:expired_pool)
    assert pool.invite_expired?
  end

  test "invite_valid? returns true for future event" do
    pool = betting_pools(:private_pool)
    assert pool.invite_valid?
  end

  test "invite_valid? returns false for past event" do
    pool = betting_pools(:expired_pool)
    assert_not pool.invite_valid?
  end

  test "regenerate_invite_code! changes the invite code" do
    pool = betting_pools(:private_pool)
    old_code = pool.invite_code
    pool.regenerate_invite_code!
    assert_not_equal old_code, pool.invite_code
    assert_equal 8, pool.invite_code.length
  end

  test "invite code validates length" do
    pool = betting_pools(:private_pool)
    pool.invite_code = "short"
    assert_not pool.valid?
    assert_includes pool.errors[:invite_code], "is the wrong length (should be 8 characters)"
  end

  test "invite code validates presence" do
    pool = betting_pools(:private_pool)
    pool.invite_code = nil
    assert_not pool.valid?
    assert_includes pool.errors[:invite_code], "can't be blank"
  end

  test "invite code validates uniqueness" do
    pool1 = betting_pools(:private_pool)
    pool2 = betting_pools(:public_pool)
    pool2.invite_code = pool1.invite_code
    assert_not pool2.valid?
    assert_includes pool2.errors[:invite_code], "has already been taken"
  end
end
