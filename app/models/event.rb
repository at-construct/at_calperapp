class Event < ApplicationRecord
  belongs_to :user
  has_many :participants
  has_many :users, through: :participants
  has_many :notifications, dependent: :destroy
  
  after_destroy :delete_related_notifications

  # validate :check_overlap

  validates :name, presence: true, length: { maximum: 100 }
  validates :start, presence: true
  validates :end, presence: true

  private

  def check_overlap
    overlapping_events = Event.where.not(id: id).where('(start < :event_end) AND ("end" > :event_start)', event_end: self.end, event_start: self.start)
    errors.add(:base, 'The event overlaps with another one') if overlapping_events.exists?
  end

  def delete_related_notifications
    Notification.where(event_id: self.id).destroy_all
  end
end
