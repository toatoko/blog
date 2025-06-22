class Category < ApplicationRecord
  has_many :posts, dependent: :destroy
  validates :name,presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 50}
end
