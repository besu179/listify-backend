module ActivityLoggable
  extend ActiveSupport::Concern

  included do
    after_create :log_activity
  end

  private

  def log_activity
    # Determine the target. For Like/Comment, it's the polymorphic parent.
    # For Follow, it's the followed user. For Review, it's the Song (or maybe the review itself?).
    # Plan says: "User 1 liked Review 5".
    # Activity: actor=User1, action="liked_review", target=Review5

    target = self.try(:likeable) || self.try(:commentable) || self.try(:following) || self.try(:song)

    # Custom mapping for action names
    action_key = case self.class.name
    when "Like"
                   "liked_#{self.likeable_type.underscore}"
    when "Comment"
                   "commented_on_#{self.commentable_type.underscore}"
    when "Follow"
                   "followed_user"
    when "Review"
                   "reviewed_song"
    else
                   "created_#{self.class.name.underscore}"
    end

    Activity.create(
      actor: self.try(:user) || self.try(:follower), # Follow model uses 'follower'
      action_type: action_key,
      target: target
    )
  end
end
