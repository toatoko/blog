class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  enum :role, [ :user, :admin ]
  after_initialize :set_default_role, if: :new_record?

  def self.ransackable_attributes(auth_object = nil)
    [ "email", "name", "id" ]
  end

  private
  def set_default_role
    self.role ||= :user
  end
end
