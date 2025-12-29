class Album < ApplicationRecord
  has_many :songs, dependent: :nullify

  validates :title, presence: true
  validates :artist_name, presence: true
end
