class Comment < ApplicationRecord
  include ActivityLoggable
  belongs_to :user
  belongs_to :commentable, polymorphic: true
end
