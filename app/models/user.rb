class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  # Associations
  has_many :reviews, dependent: :destroy
  has_many :collections, dependent: :destroy

  # Social Graph Associations
  has_many :active_follows, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_follows, class_name: "Follow", foreign_key: "following_id", dependent: :destroy

  has_many :followings, through: :active_follows, source: :following
  has_many :followers, through: :passive_follows, source: :follower

  # Validations
  validates :username, presence: true, uniqueness: true
end
