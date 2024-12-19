class AdvertisementsController < ApplicationController
    def show
        @advert = Advertisement.find_by(id: params[:id])
        if @advert.nil?
            render json: {message: 'No such advertisement!'}, status: :internal_server_error
            return
        end

        @user = @advert.user
        photos_urls = @advert.photos.map { |photo| url_for(photo) }
        avatar_url = @user.avatar.attached? ? url_for(@user.avatar) : nil

        render json: {
        advertisement: @advert.as_json(),
        owner: {
                id: @user.id,
                surname: @user.surname,
                name: @user.name,
                avatar: avatar_url # Ensure avatar is included here
            },
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
        @adv = Advertisement.all #.includes(:photos) # Eager load photos to avoid N+1 queries
        if @adv
            ads_json = @adv.map do |advert|
                {
                    advertisement: advert.as_json(),
                    owner: advert.user.as_json(only: [:id, :surname, :name, :email]),
                    photos: advert.photos.map { |photo| url_for(photo) }
                }
            end
            render json: ads_json, status: :ok
        else
            render json: { error: 'User not found' }, status: :not_found
        end
    end
    
    def filter
        # Extract parameters from the request
        sort = params[:sort]
        kind = params[:kind]
        text = params[:text]

        ads = Advertisement.all

        # Filter by type if provided
        if sort.present?
            puts 'SSOORRTT'
            ads = ads.where(sort: sort) # Assuming 'status' is used to denote 'found' or 'lost'
        end

        if kind.present?
            ads = ads.where(kind: kind)
        end

        if text.present?
            # Use LOWER for case-insensitive search in SQLite
            ads = ads.where("LOWER(title) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?)", "%#{text}%", "%#{text}%")
        end

        ads_json = ads.map do |advert|
            {
              advertisement: advert.as_json(),
              owner: advert.user.as_json(only: [:id, :surname, :name, :email]),
              photos: advert.photos.map { |photo| url_for(photo) }
            }
        end
        
        render json: ads_json, status: :ok
    end

private

    def advertisement_params
        params.require(:advertisement).permit(:title, :description, :sort, :kind, :status, :location, photos: [])
    end

    def user_data(adv)
        {
          id: adv.id,
          title: adv.title,
          description: adv.description,
          location: adv.location,
          photos: adv.photos_urls,
        }
    end
end
