class AuthenticationController < ApplicationController
  include JwtToken

  skip_before_action :authenticate_user

  def login
    @user = User.find_by_email(params[:email])
    if @user&.authenticate(params[:password])
      token = jwt_encode(user_id: @user.id)
      time = Time.now + 24.hours.to_i
      render json: {token: token, exp: time.strftime("%m-%d-%Y %H:%M"), username: @user.name, status: :ok}
    else
      render json: {error: 'unauthorized'}, status: :unauthorized
    end
  end

  def register
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: 201
    else
      render json: @user.errors.full_messages, status: 503
    end
  end

  def user_params
    params.permit(:name, :email, :password, :dateOfBirth)
  end
end
