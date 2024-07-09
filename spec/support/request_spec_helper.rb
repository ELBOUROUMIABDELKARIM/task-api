# spec/support/request_spec_helper.rb
module RequestSpecHelper
  def login_user(user)
    post '/auth/login', params: { email: user.email, password: user.password }
    JSON.parse(response.body)['token']
  end

  def authenticated_header(user)
    token = login_user(user)
    { 'Authorization': "Bearer #{token}" }
  end
end
