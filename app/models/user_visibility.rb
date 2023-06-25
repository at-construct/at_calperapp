class UserVisibility < ApplicationRecord
  belongs_to :user
  belongs_to :target_user, class_name: 'User'

  validates :user_id, presence: true
  validates :target_user_id, presence: true
  validates :visibility, inclusion: { in: [true, false] }
end