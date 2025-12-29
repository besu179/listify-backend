class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  # Associations (we’ll expand later)
  has_many :reviews, dependent: :destroy
  has_many :collections, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: true
end
