class Calendar < ApplicationRecord

  has_many :groups, dependent: :destroy
  has_many :users

  validates :name, presence: true, length: { maximum: 100 }
end
