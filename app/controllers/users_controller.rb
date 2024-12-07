require 'json'
require 'redis'

class UsersController < ApplicationController
  # here user shoud login his account.
  def sign_in
    @request_body = request.body.read
    @params = JSON.parse(@request_body)['user']

    @user = User.find_by(email: @params['email'])

    if @user && @user.authenticate(@params['password'])
      token = self.encode(user_id: @user.id)
      render json: { token: token, user: @user.as_json(only: [:id, :surname, :name, :email]) }, status: :ok
    else
      render json: { message: "Invalid email or password" }, status: :unauthorized
    end
  end

  # step of registration.
  def sign_up
    @request_body = request.body.read
    @params = JSON.parse(@request_body)['user']
    @user = User.new(surname: @params['surname'], name: @params['name'], email: @params['email'], password: @params['password'])
    if User.find_by(email: @params['email']) != nil
      render json: {message: "User with such email already exist"}, status: :unprocessable_entity
      return
    end

    @confirmation_code = rand(1000..9999)
    data = { surname: @params['surname'], name: @params['name'], password: @params['password'], email: @params['email'], confirmation_code: @confirmation_code }
    redis = Redis.new
    redis.set(@params['email'], data.to_json, ex: 10.minutes)
    UserMailer.confirmation_email(@user, @confirmation_code).deliver_now
    keys = redis.keys('*')
    data = keys.map { |key| [key, redis.get(key)] }.to_h
    render json: {message: "successful send code to email", data: data}, status: :ok
  end

  def confirm_account
    @request_body = request.body.read
    @email = JSON.parse(@request_body)['email']
    @code = JSON.parse(@request_body)['confirmation_code']

    redis = Redis.new
    @data_json = redis.get(@email)
    if @data_json.nil?
      keys = redis.keys('*')
      @dta = keys.map { |key| [key, redis.get(key)] }.to_h
      render json: {message: "Time has been expired!", redis: @dta}, status: :internal_server_error
      return
    end

    @data = JSON.parse(@data_json)
    @user = User.new(surname: @data['surname'], name: @data['name'], email: @data['email'], password: @data['password'])
    
    if @code != @data['confirmation_code']
      render json: {message: "Wrong confirmation code!"}, status: :bad_request
      return
    end
    if @user.save
      render json: {message: "successful User Creation", user: @user.as_json(only: [:id, :surname, :name, :email]) }, status: :created
    else
      render json: {message: "User creation failed", errors: @user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  # delete user's account.
  def drop_user
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

  private

  # permit user's data
  def user_params
    params.require(:user).permit(:surname, :name, :email, :password, :id, :tocken)
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
