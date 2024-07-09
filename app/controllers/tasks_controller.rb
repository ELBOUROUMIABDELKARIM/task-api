require 'byebug'

class TasksController < ApplicationController

  before_action :find_task, only: [:show, :update, :destroy]
  before_action :authenticate_user
  def index
    @tasks = Task.joins(:user).where(users: {id: @current_user.id})
    render json: @tasks
  end


  def show
    render json: @task
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      render json: @task, status: :created, location: @task
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      render json: @task
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
  end

  private

  def find_task
    begin
    @task = Task.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
    end
  end

  def task_params
    params.require(:task).permit(:title, :description, :completed, :user_id)
  end
end
