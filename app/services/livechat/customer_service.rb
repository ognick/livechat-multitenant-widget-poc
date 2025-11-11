require "net/http"
require "uri"
require "json"
require "httparty"

# frozen_string_literal: true

module Livechat
  class CustomerService
    include HTTParty
    # Credentials
    CLIENT_ID        = Rails.application.credentials.dig(:livechat, :client_id)
    ORGANIZATION_ID  = Rails.application.credentials.dig(:livechat, :organization_id)
    LICENSE_ID       = Rails.application.credentials.dig(:livechat, :license_id)

    class << self
      def fetch_or_refresh!(user_id:, casino_url:)
        customer = LivechatCustomer.find_by(user_id: user_id)
        if customer&.access_token
          return build_payload(customer)
        end

        data = request_token(customer:, redirect_uri: casino_url)

        customer = upsert_customer!(user_id:, data:)

        update_customer_casino_url(
          user_id: user_id,
          access_token: customer.access_token,
          casino_url: casino_url
        )

        build_payload(customer)
      end

      private

      def request_token(customer:, redirect_uri:)
        url = URI("https://accounts.livechat.com/v2/customer/token")
        headers = { "Content-Type" => "application/json" }

        # If we have previous cookies, send them to continue the session
        if customer&.entity_id && customer&.access_token
          headers["Cookie"] = "__lc_cid=#{customer.entity_id}; __lc_cst=#{customer.access_token}"
        end

        payload = {
          grant_type:      "cookie",
          client_id:       CLIENT_ID,
          response_type:   "token",
          organization_id: ORGANIZATION_ID,
          redirect_uri:    redirect_uri
        }

        Rails.logger.info "[Livechat::CustomerService] Requesting token with payload: #{payload.inspect}"
        Rails.logger.debug "[Livechat::CustomerService] Headers: #{headers.inspect}"
        Rails.logger.debug "[Livechat::CustomerService] Redirect URI: #{redirect_uri}"

        response = HTTParty.post(
          "https://accounts.livechat.com/v2/customer/token",
          headers: headers,
          body: payload.to_json
        )

        Rails.logger.debug "[Livechat::CustomerService] Response status: #{response.code}"

        resp = response.parsed_response
        Rails.logger.error "[Livechat] API response: #{resp.inspect}" unless resp["access_token"]
        resp
      end

      def upsert_customer!(user_id:, data:)
        unless data["access_token"]
          raise "LiveChat API did not return access_token. Response: #{data.inspect}"
        end

        customer = LivechatCustomer.find_or_initialize_by(user_id: user_id)
        customer.assign_attributes(
          access_token: data["access_token"],
          client_id:    data["client_id"],
          entity_id:    data["entity_id"],
          expires_in:   data["expires_in"],
          token_type:   data["token_type"],
        )
        customer.id ||= SecureRandom.uuid
        customer.save!
        customer
      end

      def update_customer_casino_url(user_id:, access_token:, casino_url:)
        return unless access_token && ORGANIZATION_ID && casino_url

        url = "https://api.livechatinc.com/v3.6/customer/action/update_customer?organization_id=#{ORGANIZATION_ID}"

        headers = {
          "Authorization" => "Bearer #{access_token}",
          "Content-Type"  => "application/json"
        }

        username = User.find_by(id: user_id).username
        payload = {
          name:  username,
          email: "#{username}@example.com",
          session_fields: [{ casino_url: casino_url }]
        }

        HTTParty.post(url, headers: headers, body: payload.to_json)
      rescue => e
        Rails.logger.warn "[Livechat] update_customer_casino_url failed: #{e.class} #{e.message}"
      end

      def build_payload(customer)
        {
          accessToken:  customer.access_token,
          clientID:     customer.client_id,
          entityId:     customer.entity_id,
          expiresIn:    customer.expires_in,
          tokenType:    customer.token_type,
          creationDate: (Time.now.to_i * 1000),
          licenseId:    LICENSE_ID.to_i
        }
      end
    end
  end
end
