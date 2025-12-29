class Follow < ApplicationRecord
  include ActivityLoggable
  belongs_to :follower, class_name: "User"
  belongs_to :following, class_name: "User"

  after_create :create_notification

  validates :follower_id, presence: true
  validates :following_id, presence: true
  validates :follower_id, uniqueness: { scope: :following_id }
  validate :cannot_follow_self

  private

  def create_notification
    Notification.create(
      recipient: following,
      actor: follower,
      action: "followed",
      notifiable: self
    )
  end

  def cannot_follow_self
    errors.add(:follower_id, "cannot follow self") if follower_id == following_id
  end
end
