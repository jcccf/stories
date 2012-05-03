require 'ostruct'

class User < ActiveRecord::Base
  has_many :storylines
  
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i }, uniqueness: true
  has_secure_password
  
  serialize :preferences, OpenStruct
end
