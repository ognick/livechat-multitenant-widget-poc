Rails.application.routes.draw do
  root 'casino#index'

  get "up" => "rails/health#show", as: :rails_health_check

  get "/livechat/customer-token", to: "livechat#customer_token"

  get "/get-user-data", to: "user_data#get_user_data"
  match "/get-user-data", to: "user_data#options", via: [:options]
 
  # It is not casino page, shoud be deployed on a separate domain
  get "/agent-app-widget", to: "static#agent_app_widget"
  match "/agent-app-widget", to: "static#options", via: [:options]
end
