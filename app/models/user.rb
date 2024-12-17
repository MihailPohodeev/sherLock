class User < ApplicationRecord
    has_secure_password
    has_many :advertisements
    has_one_attached :avatar
    
    validates :surname, presence: true
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true, on: :create
    validates :password, presence: true, length: { minimum: 6 }, on: :create
    # validates :avatar, content_type: ['image/png', 'image/jpg', 'image/jpeg', 'image/gif'],
    #                size: { less_than: 5.megabytes, message: 'is too large' }
end
