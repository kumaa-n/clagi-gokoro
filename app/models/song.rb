class Song < ApplicationRecord
  validates :title, presence: true, length: { maximum: 100 }
  validates :composer, length: { maximum: 50 }, allow_blank: true
  validates :arranger, length: { maximum: 50 }, allow_blank: true
end
