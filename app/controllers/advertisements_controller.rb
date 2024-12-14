class AdvertisementsController < ApplicationController
    def show
        @advert = Advertisement.find_by(id: params[:id])
        if @advert.nil?
            render json: {message: 'No such advertisement!'}, status: :internal_server_error
            return
        end

        @user = @advert.user
        photos_urls = @advert.photos.map { |photo| url_for(photo) }

        render json: {
        advertisement: @advert.as_json(include: :photos),
        owner: @user.as_json(only: [:id, :surname, :name, :email]),
        photos: photos_urls
    }, status: :ok
    end

    def create
        @user = User.find_by(id: params['user_id'])
        if @user.nil?
            render json: { message: "Пользователь не найден", status: "error" }, status: :not_found
            return
        else
            puts "User was found successfully!"
        end
        @adv = Advertisement.new(advertisement_params)
        @adv.user = @user

        if @adv.save
            render json: {message: "successful Advertisement Creation", advertisement: @adv.as_json(only: [:id, :title, :description, :status]), status: "success"}, status: :created
        else
            render json: {message: "Advertisement creation failed", errors: @adv.errors.full_messages, status: "error"}, status: :unprocessable_entity
        end
    end

    def all
        @adv = Advertisement.all
        render json: @adv        
    end
private

    def advertisement_params
        params.require(:advertisement).permit(:title, :description, :state, photos: [])
    end
end
