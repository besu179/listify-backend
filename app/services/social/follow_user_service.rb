class Social::FollowUserService < BaseService
  def initialize(follower, following_id)
    @follower = follower
    @following_id = following_id
  end

  def call
    return failure("You cannot follow yourself") if @follower.id == @following_id.to_i

    following = User.find_by(id: @following_id)
    return failure("User not found") unless following

    follow = @follower.active_follows.build(following: following)

    if follow.save
      # Activity and Notification are currently handled by callbacks/concerns in Follow model.
      # In a full refactor, we might want to move them here for explicit control.
      # For Phase 1, we ensure the service handles the core transaction.
      success(follow)
    else
      failure(follow.errors.full_messages)
    end
  rescue ActiveRecord::RecordNotUnique
    failure("Already following this user")
  rescue StandardError => e
    failure(e.message)
  end
end
