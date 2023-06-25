class Event < ApplicationRecord
  belongs_to :user
  has_many :participants
  has_many :users, through: :participants

  
  # バリデーションの設定を追加
  validates :name, presence: true, length: { maximum: 100 }
  validates :start, presence: true
  validates :end, presence: true
end
