class PhotosController < ApplicationController
    @photo = Photo.new(photo_params)

    if @photo.save
      # Успешно сохранено
    else
      # Обработка ошибок
    end

private

    def photo_params
        params.require(:photo).permit(:image)
    end
    
  end
end
