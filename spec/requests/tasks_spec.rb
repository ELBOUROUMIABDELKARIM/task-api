# spec/requests/tasks_spec.rb
require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let!(:user) { create(:user, :user) }
  let!(:admin) { create(:user, :admin) }
  let!(:moderator) { create(:user, :moderator) }
  let!(:assigned_user) { create(:user, :user) }
  let!(:tasks) { create_list(:task, 3, user: admin) }
  let(:headers) { authenticated_header(user) }
  let(:admin_headers) { authenticated_header(admin) }
  let(:moderator_headers) { authenticated_header(moderator) }
  let(:assigned_user_headers) { authenticated_header(assigned_user) }

  describe "GET /tasks" do
    context "when the user is admin or moderator" do
      it "returns all tasks" do
        get '/tasks', headers: admin_headers
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["tasks"].size).to eq(3)

        get '/tasks', headers: moderator_headers
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["tasks"].size).to eq(3)
      end
    end

    context "when the user is a regular user" do
      it "returns tasks created or assigned to the user" do
        assigned_task = tasks.first
        assigned_task.update!(assigned_user_id: user.id)

        get '/tasks', headers: headers
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["tasks"].size).to eq(1)
        expect(json_response["tasks"].first["id"]).to eq(assigned_task.id)
      end
    end

    context "when the request is unauthorized" do
      it "returns an unauthorized response" do
        get '/tasks'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /tasks/:id" do
    let(:task) { tasks.first }

    context "when the user is authorized" do
      it "returns the task for admin" do
        get "/tasks/#{task.id}", headers: admin_headers
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to eq(task.id)
        expect(json_response["user_id"]).to eq(admin.id)
      end

      it "returns the task for moderator" do
        get "/tasks/#{task.id}", headers: moderator_headers
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to eq(task.id)
        expect(json_response["user_id"]).to eq(admin.id)
      end
    end

    context "when the id is not valid" do
      it "returns a not found response" do
        get "/tasks/00", headers: headers
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Task not found")
      end
    end

    context "when the request is unauthorized" do
      it "returns an unauthorized response" do
        get "/tasks/#{task.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /tasks" do
    let(:valid_attributes) { { task: { title: "New Task", description: "Task description", completed: false } } }

    context "when the user is authorized" do
      it "creates a new task" do
        post '/tasks', params: valid_attributes, headers: admin_headers
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["title"]).to eq("New Task")
        expect(json_response["user_id"]).to eq(admin.id)
      end
    end

    context "when the request is invalid" do
      it "returns unprocessable entity" do
        post '/tasks', params: { task: { title: "" } }, headers: admin_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the user is unauthorized" do
      it "returns a forbidden response" do
        allow_any_instance_of(User).to receive(:can_create_task?).and_return(false)
        post '/tasks', params: valid_attributes, headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT /tasks/:id" do
    let(:task) { tasks.first }
    let(:valid_attributes) { { task: { title: "Updated Task", description: "Updated description" } } }

    context "when the user is authorized" do
      it "updates the task" do
        put "/tasks/#{task.id}", params: valid_attributes, headers: admin_headers
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["title"]).to eq("Updated Task")
      end
    end

    context "when the id is not valid" do
      it "returns a not found response" do
        put "/tasks/00", params: valid_attributes, headers: headers
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Task not found")
      end
    end

    context "when the request is invalid" do
      it "returns unprocessable entity" do
        put "/tasks/#{task.id}", params: { task: { title: "" } }, headers: admin_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the user is unauthorized" do
      it "returns a forbidden response" do
        allow_any_instance_of(User).to receive(:can_update_task?).and_return(false)
        put "/tasks/#{task.id}", params: valid_attributes, headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /tasks/:id" do
    let(:task) { tasks.first }

    context "when the user is authorized" do
      it "deletes the task" do
        delete "/tasks/#{task.id}", headers: admin_headers
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when the id is not valid" do
      it "returns a not found response" do
        delete "/tasks/00", headers: headers
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Task not found")
      end
    end

    context "when the user is unauthorized" do
      it "returns a forbidden response" do
        allow_any_instance_of(User).to receive(:can_delete_task?).and_return(false)
        delete "/tasks/#{task.id}", headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /tasks/:id/assign" do
    let(:task) { tasks.first }

    context "when the user is authorized" do
      it "assigns the task to another user" do
        patch "/tasks/#{task.id}/assign", params: { assigned_user_id: assigned_user.id }, headers: admin_headers
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["assigned_user_id"]).to eq(assigned_user.id)
      end

      it "returns not found if the assigned user does not exist" do
        patch "/tasks/#{task.id}/assign", params: { assigned_user_id: 0 }, headers: admin_headers
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Assigned user not found")
      end

      it "returns not acceptable if the assigned user does not have the user role" do
        assigned_user.update(role: :admin)
        patch "/tasks/#{task.id}/assign", params: { assigned_user_id: assigned_user.id }, headers: admin_headers
        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Task can only be assigned to users with the user role")
      end
    end

    context "when the user is unauthorized" do
      it "returns a forbidden response" do
        allow_any_instance_of(User).to receive(:can_assign_task?).and_return(false)
        patch "/tasks/#{task.id}/assign", params: { assigned_user_id: assigned_user.id }, headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
