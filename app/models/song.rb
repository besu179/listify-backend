class Song < ApplicationRecord
  belongs_to :album, optional: true

  validates :title, presence: true
  validates :artist_name, presence: true

  has_many :reviews, dependent: :destroy
end
