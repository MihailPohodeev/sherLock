class Photo < ApplicationRecord
    belongs_to :advertisement
    has_one_attached :image
end
