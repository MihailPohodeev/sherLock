class Advertisement < ApplicationRecord
    belongs_to :user
    has_many_attached :photos

    validates :title, presence: true, on: :create
    validates :description, presence: true, on: :create
    validates :location, presence: true, on: :create
    validates :kind, presence: true, on: :create
    validates :sort, presence: true, on: :create
    validates :status, presence: true, on: :create
end
