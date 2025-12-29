class Like < ApplicationRecord
  include ActivityLoggable
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  validates :user_id, uniqueness: { scope: [ :likeable_type, :likeable_id ], message: "has already liked this" }

  after_create :create_notification

  private

  def create_notification
    # Notify the owner of the object being liked
    return unless likeable.respond_to?(:user) && likeable.user.present?
    return if user_id == likeable.user_id # Don't notify self

    Notification.create(
      recipient: likeable.user,
      actor: user,
      action: "liked",
      notifiable: self
    )
  end
end
