class Bearer < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :stocks
end
