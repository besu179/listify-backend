class Song < ApplicationRecord
  belongs_to :artist, optional: true
  belongs_to :album, optional: true

  validates :title, presence: true
  validates :artist_name, presence: true

  has_one_attached :cover_art

  has_many :reviews, dependent: :destroy

  validate :validate_cover_art

  private

  def validate_cover_art
    return unless cover_art.attached?

    if cover_art.blob.byte_size > 5.megabytes
      errors.add(:cover_art, "is too big (max 5MB)")
    end

    acceptable_types = [ "image/jpeg", "image/png", "image/webp" ]
    unless acceptable_types.include?(cover_art.content_type)
      errors.add(:cover_art, "must be a JPEG, PNG or WEBP")
    end
  end
end
