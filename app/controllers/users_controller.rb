require 'json'
require 'redis'

class UsersController < ApplicationController
  
  # here user shoud login his account.
  def login
    @request_body = request.body.read
    @params = JSON.parse(@request_body)['user']

    @user = User.find_by(email: @params['email'])

    if @user && @user.authenticate(@params['password'])
      token = self.encode(user_id: @user.id)
      render json: { token: token, user: user_data(@user) }, status: :ok
    else
      render json: { message: "Неверный логин или пароль..." }, status: :unauthorized
    end
  end

  # get user's data
  def show
    user = User.find_by(id: params[:id])
    if user.nil?
      render json: {message: "User not found!"}, status: :not_found
    end
    render json: user_data(user), status: :ok #user.as_json(only: [:id, :surname, :name])
  end

  # step of registration.
  def create
    @request_body = request.body.read
    @params = JSON.parse(@request_body)['user']
    @user = User.new(surname: @params['surname'], name: @params['name'], email: @params['email'], password: @params['password'])
    if User.find_by(email: @params['email']) != nil
      render json: {message: "Пользователь с таким email уже существует!"}, status: :bad_request
      return
    end

    @confirmation_code = rand(1000..9999)
    puts @confirmation_code
    data = { surname: @params['surname'], name: @params['name'], password: @params['password'], email: @params['email'], confirmation_code: @confirmation_code }
    redis = Redis.new
    redis.set(@params['email'], data.to_json, ex: 10.minutes)
    #UserMailer.confirmation_email(@user, @confirmation_code).deliver_now
    keys = redis.keys('*')
    data = keys.map { |key| [key, redis.get(key)] }.to_h
    render json: {message: "successful send code to email", data: data}, status: :ok
  end

  def confirm
    @email = params['email']
    @code = params['confirmation_code']

    puts @email
    puts @code

    redis = Redis.new
    @data_json = redis.get(@email)
    if @data_json.nil?
      render json: {message: "Время ожидания истекло!"}, status: :internal_server_error
      return
    end

    @data = JSON.parse(@data_json)
    @user = User.new(surname: @data['surname'], name: @data['name'], email: @data['email'], password: @data['password'])
    puts user_data(@user)
    puts @data
    
    if @code != @data['confirmation_code']
      render json: {message: "Неверный код подтверждения!"}, status: :bad_request
      return
    end
    if @user.save
      render json: {message: "successful User Creation", user: @user.as_json(only: [:id, :surname, :name, :email]) }, status: :created
    else
      render json: {message: "User creation failed", errors: @user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  # delete user's account.
  def destroy
    @request_body = request.body.read
    @params = JSON.parse(@request_body)

    @id = get_user_id(@params['user']['token'])
    if @id.nil?
      render json: { message: 'Invalid token!' }, status: :internal_server_error
      return
    end
    
    @user = User.find_by(id: @id)
    if @user.nil?
      render json: { message: 'No such user!'}, status: :internal_server_error
      return
    end
    @name = @user.surname + ' ' + @user.name
    if @user.destroy
      render json: { message: 'User ' + @name + ' successfully deleted!'}, status: :ok
    else
      render json: { message: 'Can\'t destroy user'}, status: :errors
    end
  end

  def update
    @user = User.find(params[:id])
    Rails.logger.debug("Received params: #{params.inspect}")
    if @user.update(avatar_params)
      render json: { message: 'User updated successfully', user: user_data(@user) }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  #return all user's advertisements.
  def advertisement_of_user
    user = User.find_by(id: params[:id])
    if user
        advertisements = user.advertisements.includes(:user)
        ads_json = advertisements.map do |advert|
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

  def update_avatar
    if @user.update(avatar_params)
      render json: { message: 'Avatar uploaded successfully', avatar_url: url_for(@user.avatar) }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # permit user's data
  def user_params
    params.require(:user).permit(:surname, :name, :email, :password, :id, :token, :avatar)
  end

  def avatar_params
    params.require(:user).permit(:avatar, :id, :name, :surname)
  end

  # user's data.
  def user_data(user)
    {
      id: user.id,
      name: user.name,
      surname: user.surname,
      email: user.email,
      avatar: user.avatar.attached? ? url_for(user.avatar) : nil # Generates the URL for the avatar
    }
  end

  # work with token
  SECRET_KEY = Rails.application.credentials.secret_key_base
  
  def encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def decode(token)
    body = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new body
    rescue JWT::DecodeError
    nil
  end

  def get_user_id(token)
    @id = decode(token)['user_id']
  end

end
