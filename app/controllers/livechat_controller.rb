class LivechatController < ApplicationController
  def customer_token
    uid = cookies.signed[:user_id]
    return render json: { error: "missing user_id cookie" }, status: :unauthorized unless uid

    payload = Livechat::CustomerService.fetch_or_refresh!(
      user_id: uid,
      casino_url: root_url
    )

    render json: payload
  rescue => e
    Rails.logger.error "[Livechat] customer_token failed: #{e.class} #{e.message}"
    render json: { error: "token_fetch_failed" }, status: :bad_gateway
  end
end
