class Song < ApplicationRecord
  belongs_to :artist, optional: true
  belongs_to :album, optional: true

  validates :title, presence: true
  validates :artist_name, presence: true

  has_one_attached :cover_art

  has_many :reviews, dependent: :destroy
end
