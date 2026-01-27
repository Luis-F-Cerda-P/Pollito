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

  # Validation tests
  test "validates creator presence" do
    pool = BettingPool.new(
      name: "Test Pool",
      event: events(:world_cup),
      creator: nil
    )
    assert_not pool.valid?
    assert_includes pool.errors[:creator], "must exist"
  end

  test "validates name presence" do
    pool = BettingPool.new(
      name: nil,
      event: events(:world_cup),
      creator: users(:admin_user)
    )
    assert_not pool.valid?
    assert_includes pool.errors[:name], "can't be blank"
  end

  test "validates name uniqueness within same event" do
    existing_pool = betting_pools(:private_pool)
    pool = BettingPool.new(
      name: existing_pool.name,
      event: existing_pool.event,
      creator: users(:regular_user)
    )
    assert_not pool.valid?
    assert_includes pool.errors[:name], "must be unique within this event"
  end

  test "allows same name in different events" do
    existing_pool = betting_pools(:private_pool)
    pool = BettingPool.new(
      name: existing_pool.name,
      event: events(:past_event),
      creator: users(:regular_user)
    )
    assert pool.valid?
  end

  # Callback tests
  test "adds creator to members after creation" do
    pool = BettingPool.create!(
      name: "Creator Membership Pool",
      event: events(:world_cup),
      creator: users(:regular_user)
    )
    assert pool.user_in_pool?(users(:regular_user))
    assert_equal 1, pool.member_count
  end

  # Scope tests
  test "visible_to returns public pools" do
    user = users(:regular_user)
    visible_pools = BettingPool.visible_to(user)
    assert_includes visible_pools, betting_pools(:public_pool)
  end

  test "visible_to returns pools user is member of" do
    user = users(:admin_user)
    visible_pools = BettingPool.visible_to(user)
    assert_includes visible_pools, betting_pools(:private_pool)
  end

  test "visible_to excludes private pools user is not member of" do
    user = users(:regular_user)
    visible_pools = BettingPool.visible_to(user)
    assert_not_includes visible_pools, betting_pools(:private_pool)
  end

  # Instance method tests
  test "add_user adds user to pool" do
    pool = betting_pools(:private_pool)
    user = users(:regular_user)
    assert_not pool.user_in_pool?(user)

    result = pool.add_user(user)

    assert result
    assert pool.user_in_pool?(user)
  end

  test "add_user returns false if user already in pool" do
    pool = betting_pools(:private_pool)
    user = users(:admin_user)
    assert pool.user_in_pool?(user)

    result = pool.add_user(user)

    assert_equal false, result
  end

  test "remove_user removes user from pool" do
    pool = betting_pools(:private_pool)
    user = users(:admin_user)
    assert pool.user_in_pool?(user)

    pool.remove_user(user)

    assert_not pool.user_in_pool?(user)
  end

  test "remove_user returns nil if user not in pool" do
    pool = betting_pools(:private_pool)
    user = users(:regular_user)
    assert_not pool.user_in_pool?(user)

    result = pool.remove_user(user)

    assert_nil result
  end

  test "user_in_pool? returns true for member" do
    pool = betting_pools(:private_pool)
    user = users(:admin_user)
    assert pool.user_in_pool?(user)
  end

  test "user_in_pool? returns false for non-member" do
    pool = betting_pools(:private_pool)
    user = users(:regular_user)
    assert_not pool.user_in_pool?(user)
  end

  test "member_count returns correct count" do
    pool = betting_pools(:private_pool)
    assert_equal 1, pool.member_count

    pool.add_user(users(:regular_user))
    assert_equal 2, pool.member_count
  end
end
