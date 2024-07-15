# frozen_string_literal: true

# Handles user authentication, including login and registration.
class AuthenticationController < ApplicationController
  include JwtToken

  skip_before_action :authenticate_user

  def login
    user = User.find_by_email(params[:email])
    if user&.authenticate(params[:password])
      render_successful_login(user)
    else
      render_unauthorized
    end
  end

  def register
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :role, :dateOfBirth)
  end

  def render_successful_login(user)
    token = jwt_encode(user_id: user.id, role: user.role)
    exp_time = 24.hours.from_now
    render json: {
      token:,
      exp: exp_time.strftime('%m-%d-%Y %H:%M'),
      username: user.name,
      status: :ok
    }
  end

  def render_unauthorized
    render json: { error: 'Unauthorized. Invalid email or password.' }, status: :unauthorized
  end
end
