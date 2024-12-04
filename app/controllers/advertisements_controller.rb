class AdvertisementsController < ApplicationController
    def get_advertisement
        @advert = Advertisement.find(advertisement_params[:id])
        if @advert.nil?
            render json: {status: 'error', message: 'No such advertisement!'}, status: :internal_server_error
        end

        @user = @advert.user

        render json: {status: 'success', advertisement: @advert.as_json(only: [:title, :description]), owner: @user.as_json(only: [:id, :surname, :name, :email])}, status: :ok
    end

    def create_advertisement
        @request_body = request.body.read
        @params = JSON.parse(@request_body)['advertisement']

        @user = User.find_by(id: @params['user_id'])
        @adv = Advertisement.new(title: @params['title'], description: @params['description'], user: @user, state: @params['state'], status: 'active')
        if @adv.save
            render json: {message: "successful Advertisement Creation", advertisement: @adv.as_json(only: [:id, :title, :description, :status]), status: "success"}, status: :created
        else
            render json: {message: "Advertisement creation failed", errors: @adv.errors.full_messages, status: "error"}, status: :unprocessable_entity
        end
    end
private

    def advertisement_params
        params.require(:advertisement).permit(:id, :title, :description, photos: [])
      end

end
