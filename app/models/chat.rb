class Chat < ApplicationRecord
  belongs_to :advertisement
  belongs_to :user # Пользователь, который создал чат
  has_many :messages, dependent: :destroy

  validates :advertisement_id, presence: true
  validates :user_id, presence: true
end
