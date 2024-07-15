# frozen_string_literal: true

# Manages tasks including creation, updates, and assignment.
class TasksController < ApplicationController
  before_action :authenticate_user
  before_action :find_task, only: %i[show update destroy assign]
  before_action :authorize_create, only: [:create]
  before_action :authorize_update, only: [:update]
  before_action :authorize_destroy, only: [:destroy]
  before_action :authorize_show, only: [:show]
  before_action :authorize_assign, only: [:assign]

  def index
    @tasks = if @current_user.role?(:admin) || @current_user.role?(:moderator)
               Task.page(params[:page]).per(10)
             else
               Task.where('user_id = ? OR assigned_user_id = ?', @current_user.id, @current_user.id)
                   .page(params[:page]).per(10)
             end
    render json: {
      tasks: @tasks,
      current_page: @tasks.current_page,
      total_pages: @tasks.total_pages,
      total_count: @tasks.total_count
    }, status: :ok
  end

  def show
    render json: @task, status: :ok
  end

  def create
    @task = Task.new(task_params)
    @task.user = @current_user
    if @task.save
      render json: @task, status: :created, location: @task
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      render json: @task, status: :ok
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @task.destroy
      render status: :no_content
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def assign
    assigned_user = User.find_by(id: params[:assigned_user_id])

    if assigned_user.nil?
      return render json: { error: 'Assigned user not found' }, status: :not_found
    end

    unless assigned_user.role?(:user)
      return render json: { error: 'Task can only be assigned to users with the user role' }, status: :forbidden # 403
    end

    if @task.assigned_user_id == assigned_user.id
      return render json: { message: 'This task is already assigned to the specified user' }, status: :unprocessable_entity # 422
    end

    if @task.assign_to(assigned_user)
      MailerWorker.perform_async(@task.id)
      render json: @task, status: :ok
    else
      render json: { error: 'Unable to assign task' }, status: :unprocessable_entity # 422
    end
  end

  private

  def find_task
    @task = Task.find_by(id: params[:id])
    render json: { error: 'Task not found' }, status: :not_found unless @task
  end

  def task_params
    params.require(:task).permit(:title, :description, :completed)
  end

  def authorize_create
    render json: { error: 'Not authorized to create tasks' }, status: :forbidden unless @current_user.can_create_task?
  end

  def authorize_update
    render json: { error: 'Not authorized to update this task' }, status: :forbidden unless @current_user.can_update_task?(@task)
  end

  def authorize_destroy
    render json: { error: 'Not authorized to delete this task' }, status: :forbidden unless @current_user.can_delete_task?(@task)
  end

  def authorize_show
    render json: { error: 'Not authorized to view this task' }, status: :forbidden unless @current_user.can_view_task?(@task)
  end

  def authorize_assign
    render json: { error: 'Not authorized to assign tasks' }, status: :forbidden unless @current_user.can_assign_task?
  end
end
