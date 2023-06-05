class User < ApplicationRecord
  # include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable,
  :jwt_authenticatable, jwt_revocation_strategy: self
  
  has_many :participants
  has_many :events, dependent: :destroy

  has_many :groups
  has_many :calendars


  # has_secure_password

  validates :name, presence:true, length: { maximum: 30 }
  
end
