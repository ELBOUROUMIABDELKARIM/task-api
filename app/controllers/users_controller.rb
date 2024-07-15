class UsersController < ApplicationController
  before_action :authorize_admin, only: [:create, :destroy]
  before_action :set_user, only: [:show, :destroy]
  #skip_before_action :authenticate_user, only: [:index]

  def index
    @users = User.page(params[:page]).per(10)
    render json: {
      users: @users,
      current_page: @users.current_page,
      total_pages: @users.total_pages,
      total_count: @users.total_count
    }, status: :ok
  end
  def show
    render json: @user, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    render json: { message: 'User deleted successfully' }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :role, :dateOfBirth)
  end

  def authorize_admin
    render json: { error: 'Not authorized' }, status: :forbidden unless @current_user.has_role?(:admin)
  end
end
