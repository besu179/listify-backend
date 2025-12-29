class Song < ApplicationRecord
  belongs_to :album, optional: true

  validates :title, presence: true
  validates :artist_name, presence: true
end
