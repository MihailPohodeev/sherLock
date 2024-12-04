class UsersController < ApplicationController
  # here user shoud login his account.
  def sign_in
    @request_body = request.body.read
    @params = JSON.parse(@request_body)['user']

    @user = User.find_by(email: @params['email'])

    if @user && @user.authenticate(@params['password'])
      token = self.encode(user_id: @user.id)
      render json: { status: "success", token: token, user: @user.as_json(only: [:id, :surname, :name, :email]) }, status: :ok
    else
      render json: { message: "Invalid email or password", status: "error" }, status: :unauthorized
    end
  end

  # step of registration.
  def sign_up
    @request_body = request.body.read
    @params = JSON.parse(@request_body)['user']
    @user = User.new(surname: @params['surname'], name: @params['name'], email: @params['email'], password: @params['password'])
    @confirmation_code = SecureRandom.hex(10)
    UserMailer.confirmation_email(@user, @confirmation_code).deliver_now
    if @user.save
      render json: {message: "successful User Creation", user: @user.as_json(only: [:id, :surname, :name, :email]), status: "success"}, status: :created
    else
      render json: {message: "User creation failed", errors: @user.errors.full_messages, status: "error"}, status: :unprocessable_entity
    end
  end

  # delete user's account.
  def drop_user
    @request_body = request.body.read
    @params = JSON.parse(@request_body)

    @id = get_user_id(@params['user']['token'])
    if @id.nil?
      render json: {status: 'error', message: 'Invalid token!'}, status: :internal_server_error
      return
    end
    
    @user = User.find_by(id: @id)
    if @user.nil?
      render json: {status: 'error', message: 'No such user!'}, status: :internal_server_error
      return
    end
    @name = @user.surname + ' ' + @user.name
    if @user.destroy
      render json: {status: 'success', message: 'User ' + @name + ' successfully deleted!'}, status: :ok
    else
      render json: {status: 'error', message: 'Can\'t destroy user'}, status: :errors
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
