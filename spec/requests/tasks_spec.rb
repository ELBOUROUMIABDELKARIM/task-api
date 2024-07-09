# spec/requests/tasks_spec.rb
require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let!(:user) { create(:user) }
  let!(:tasks) { create_list(:task, 3, user: user) }
  let(:headers) { authenticated_header(user) }

  describe "GET /tasks" do
    context "when the request is valid" do
      before { get '/tasks', headers: headers }

      it "returns a success response" do
        expect(response).to have_http_status(:success)
      end

      it "returns the tasks of the current user" do
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(3)
        json_response.each do |task|
          expect task["title"].to eq "Test Task"
          expect task["description"].to eq "This is a test task."
          expect(task["user_id"]).to eq(user.id)
        end
      end
    end

    context "when the request is unauthorized" do
      before { get '/tasks' }

      it "returns an unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /tasks/:id" do
    let(:task) { tasks.first }

    context "when the request is valid" do
      before { get "/tasks/#{task.id}", headers: headers }

      it "returns a success response" do
        expect(response).to have_http_status(:success)
      end

      it "returns the task" do
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to eq(task.id)
        expect(json_response["user_id"]).to eq(user.id)
      end
    end


    context "when the id not valid" do
      before { get "/tasks/00", headers: headers }

      it "returns a not found response" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns task not found message" do
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("Task not found")
      end
    end

    context "when the request is unauthorized" do
      before { get "/tasks/#{task.id}" }

      it "returns an unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

  end

  describe "POST /tasks" do
    let(:valid_attributes) { { task: { title: "New Task", description: "Task description", completed: false, user_id: user.id } } }

    context "when the request is valid" do
      before { post '/tasks', params: valid_attributes, headers: headers }

      it "creates a new task" do
        expect(response).to have_http_status(:created)
      end

      it "returns the created task" do
        json_response = JSON.parse(response.body)
        expect(json_response["title"]).to eq("New Task")
        expect(json_response["user_id"]).to eq(user.id)
      end
    end

    context "when the request is invalid" do
      before { post '/tasks', params: { task: { title: "" } }, headers: headers }

      it "returns unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT /tasks/:id" do
    let(:task) { tasks.first }
    let(:valid_attributes) { { task: { title: "Updated Task", description: "Updated description" } } }

    context "when the request is valid" do
      before { put "/tasks/#{task.id}", params: valid_attributes, headers: headers }

      it "updates the task" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the updated task" do
        json_response = JSON.parse(response.body)
        expect(json_response["title"]).to eq("Updated Task")
      end
    end

    context "when the request is invalid" do
      before { put "/tasks/#{task.id}", params: { task: { title: "" } }, headers: headers }

      it "returns unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /tasks/:id" do
    let(:task) { tasks.first }

    context "when the request is valid" do
      before { delete "/tasks/#{task.id}", headers: headers }

      it "deletes the task" do
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when the request is unauthorized" do
      before { delete "/tasks/#{task.id}" }

      it "returns an unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
