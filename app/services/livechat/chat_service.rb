# frozen_string_literal: true

require "httparty"


module Livechat
  class ChatService
    CLIENT_ID        = Rails.application.credentials.dig(:livechat, :client_id)
    BASE_ACTION_URL = "https://api.livechatinc.com/v3.6/agent/action"

    include HTTParty

    class << self
      def headers(token)
        {
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json"
        }
      end

      def update_chat_properties(token:, chat_id:, thread_id:)
        payload = {
          chat_id: chat_id,
          thread_id: thread_id,
          tag: "support",
        }

        Rails.logger.debug "[Livechat::ChatService] update_chat_properties #{headers(token)} #{payload}"

        response = HTTParty.post(
          "#{BASE_ACTION_URL}/tag_thread",
          headers: headers(token),
          body: payload.to_json,
          timeout: 10
        )

        Rails.logger.debug "[Livechat::ChatService] Response: #{response.parsed_response}"
      end

      def get_chat_data(token:, chat_id:)
        payload = { chat_id: chat_id }

        response = HTTParty.post(
          "#{BASE_ACTION_URL}/get_chat",
          headers: headers(token),
          body: payload.to_json,
          timeout: 10
        )

        Rails.logger.debug "[Livechat::ChatService] Response status: #{response.code}"
        unless response.success?
          Rails.logger.error "[Livechat::ChatService] Request failed with status #{response.code}"
          return nil
        end

        response.parsed_response
      end

      def update_chats(token:)
        payload = {
          filter: {
            active: true,
          },
        }
        response = HTTParty.post(
          "#{BASE_ACTION_URL}/list_chats",
          headers: headers(token),
          body: payload.to_json,
          timeout: 10
        )

        chats = response.parsed_response
        chats['chats_summary'].each do |cs|
          Rails.logger.debug "[Livechat::ChatService] Chat: #{cs}"
          # update_chat_properties(token: token, chat_id: cs['id'])
        end
      end

      def confirm_agent_status(chat_id:, thread_id:, entity_id:, token:)
        chat_data = get_chat_data(token: token, chat_id: chat_id)
        return false unless chat_data
        
        users = chat_data["users"] || []
        users.each do |user|
          user_entity_id = user["id"] || user["entity_id"]
          if user_entity_id == entity_id
            return true
          end
        end
        false
      end

    end
  end
end

