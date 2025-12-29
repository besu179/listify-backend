class Comment < ApplicationRecord
  include ActivityLoggable
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  after_create :create_notification

  private

  def create_notification
    # Notify the owner of the object being commented on
    return unless commentable.respond_to?(:user) && commentable.user.present?
    return if user_id == commentable.user_id # Don't notify self

    Notification.create(
      recipient: commentable.user,
      actor: user,
      action: "commented",
      notifiable: self
    )
  end
end
