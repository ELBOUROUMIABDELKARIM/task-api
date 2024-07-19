# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

# Manages tasks including creation, updates, and assignment.
class TasksController < ApplicationController
  before_action :find_task, only: %i[show update destroy assign]
  before_action :authorize_create, only: [:create]
  before_action :authorize_update, only: [:update]
  before_action :authorize_destroy, only: [:destroy]
  before_action :authorize_show, only: [:show]
  before_action :authorize_assign, only: [:assign]

  def index
    @tasks = fetch_tasks
    render json: tasks_response(@tasks), status: :ok
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
    assigned_user = find_assigned_user
    return if performed?

    if @task.assigned_user_id == assigned_user.id
      render_unprocessable('This task is already assigned to the specified user')
    elsif @task.assign_to(assigned_user)
      MailerWorker.perform_async(@task.id)
      render json: @task, status: :ok
    else
      render_unprocessable('Unable to assign task')
    end
  end

  private

  def find_assigned_user
    assigned_user = User.find_by(id: params[:assigned_user_id])
    if assigned_user.nil?
      render_not_found('Assigned user')
    elsif !assigned_user.role?(:user)
      render_forbidden('Task can only be assigned to users with the user role')
    end
    assigned_user
  end

  def fetch_tasks
    if @current_user.role?(:admin) || @current_user.role?(:moderator)
      Task.page(params[:page]).per(10)
    else
      Task.where('assigned_user_id = ?', @current_user.id)
          .page(params[:page]).per(10)
    end
  end

  def tasks_response(tasks)
    {
      tasks:,
      current_page: tasks.current_page,
      total_pages: tasks.total_pages,
      total_count: tasks.total_count
    }
  end

  def find_task
    @task = Task.find_by(id: params[:id])
    render_not_found('Task') unless @task
  end

  def task_params
    params.require(:task).permit(:title, :description, :completed, :due_date)
  end

  def authorize_create
    render_forbidden('Not authorized to create tasks') unless @current_user.can_create_task?
  end

  def authorize_update
    render_forbidden('Not authorized to update this task') unless @current_user.can_update_task?(@task)
  end

  def authorize_destroy
    render_forbidden('Not authorized to delete this task') unless @current_user.can_delete_task?(@task)
  end

  def authorize_show
    render_forbidden('Not authorized to view this task') unless @current_user.can_view_task?(@task)
  end

  def authorize_assign
    render_forbidden('Not authorized to assign tasks') unless @current_user.can_assign_task?
  end

  def render_not_found(resource)
    render json: { error: "#{resource} not found" }, status: :not_found
  end

  def render_forbidden(message)
    render json: { error: message }, status: :forbidden
  end

  def render_unprocessable(message)
    render json: { error: message }, status: :unprocessable_entity
  end
end

# rubocop:enable Metrics/ClassLength
