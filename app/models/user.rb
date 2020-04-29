# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  extend Devise::Models
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable, :confirmable
  include DeviseTokenAuth::Concerns::User

  has_many :projects
  has_many :sales
  has_many :activities, dependent: :destroy
  has_many :wishlists
  has_many :orders

  has_one_attached :image
  has_one :favourite

  before_create do |user|
    user.client_code = user.generate_client_code
  end

  def to_s
    "#{firstname} #{lastname} - #{client_code}"
  end

  def generate_client_code
    loop do
      client_code = SecureRandom.hex(3)
      break client_code unless User.exists?(client_code: client_code)
    end
  end

  def generate_password_token!
    self.reset_password_token = generate_token
    self.reset_password_sent_at = Time.now.utc
    save!
  end

  def reset_password!(password, password_confirmation)
    self.reset_password_token = nil
    self.password = password
    self.password_confirmation = password_confirmation
    save
  end

  private

  def generate_token
    SecureRandom.hex(10)
  end
end
