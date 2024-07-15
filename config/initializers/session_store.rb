Rails.application.config.session_store :cookie_store, key: '_my_app_session'
Rails.application.config.middleware.use ActionDispatch::Cookies
Rails.application.config.middleware.use ActionDispatch::Session::CookieStore, Rails.application.config.session_options
