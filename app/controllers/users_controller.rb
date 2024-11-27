class UsersController < ApplicationController
  def sign_in
    user = User.find_by(email: user_params[:email])

    if user && user.authenticate(user_params[:password]) # Ensure you check the password
      render json: { status: "success", user: user.as_json(only: [:id, :name, :email]) }, status: :ok
    else
      render json: { message: "Invalid email or password", status: "error" }, status: :unauthorized
    end
  end

  def sign_up
    user = User.new(user_params)
    
    if user.save
      render json: {message: "successful User Creation", user: user.as_json(only: [:id, :name, :email]), status: "success"}, status: :created
    else
      render json: {message: "User creation failed", errors: user.errors.full_messages, status: "error"}, status: :unprocessable_entity
    end
  end

  def sign_out
  end

  def drop_user
    user = User.find_by(id: user_params[:id])
    if user && user.authenticate(user_params[:password]) # Ensure you check the password
      user.destroy
      render json: { status: "success", user: user.as_json(only: [:id, :name, :email]) }, status: :ok
    else
      render json: { message: "Invalid email or password", status: "error" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:surname, :name, :email, :password, :id)
  end

end
