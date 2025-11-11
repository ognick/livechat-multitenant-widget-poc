class StaticController < ApplicationController
    before_action :set_cors_headers
    after_action :allow_iframe
  
    def agent_app_widget
      @client_id = Rails.application.credentials.dig(:livechat, :client_id)
    end
  
    private
  
    def set_cors_headers
      headers["Access-Control-Allow-Origin"] = "*"
      headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
      headers["Access-Control-Allow-Headers"] = "Content-Type"
    end
  
    def allow_iframe
      response.headers.except!("X-Frame-Options")
    end
  end