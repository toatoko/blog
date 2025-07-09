class User < ApplicationRecord
  include SubscriptionConcern
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :posts, dependent: :destroy
  has_one_attached :avatar, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  # Fix the counter cache setup
  has_many :notifications, as: :recipient, dependent: :destroy, 
           class_name: "Noticed::Notification"
  has_many :notification_mentions, as: :record, dependent: :destroy, 
           class_name: "Noticed::Event"
  
  # Add these for better notification querying
  has_many :unread_notifications, -> { where(read_at: nil) }, 
           as: :recipient, class_name: "Noticed::Notification"
  has_many :read_notifications, -> { where.not(read_at: nil) }, 
           as: :recipient, class_name: "Noticed::Notification"
           
  pay_customer stripe_attributes: :stripe_attributes
  has_one :address, dependent: :destroy, inverse_of: :user, autosave: true
  enum :role, [ :user, :admin ]
  after_initialize :set_default_role, if: :new_record?

  cattr_accessor :form_steps do
    %w[sign_up set_name set_address find_users]
  end
  attr_accessor :form_step
  validates_associated :address, if: -> { required_for_step?('set_address')}

  def form_step
    @form_step ||= 'sign_up'
  end
  with_options if: -> {required_for_step?('set_name')} do |step|
    step.validates :first_name, presence: true
    step.validates :last_name, presence: true
  end
  def self.ransackable_attributes(auth_object = nil)
    [ "email", "first_name", "last_name", "id" ]
  end
  def self.ransackable_associations(auth_object = nil)
    ["address", "comments", "notification_mentions", "notifications", "posts"]
  end
  def full_name
    "#{first_name.capitalize unless first_name.nil?} #{last_name.capitalize unless last_name.nil?}"
  end

  accepts_nested_attributes_for :address, allow_destroy: true

  def required_for_step?(step)
    form_step.nil?
    form_steps.index(step.to_s) <= form_steps.index(form_step.to_s)
  end
  def stripe_attributes (pay_customer)
    {
      address: {
        city: pay_customer.owner.city,
        country: pay_customer.owner.country
      },
      metadata: {
        pay_customer_id: pay_customer.id,
        user_id: id
      }
    }

  end
  def unread_notifications_count
    unread_notifications.count
  end

  private
  def set_default_role
    self.role ||= :user
  end
end
