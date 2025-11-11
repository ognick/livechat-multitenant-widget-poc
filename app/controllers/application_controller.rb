class ApplicationController < ActionController::Base
      helper_method :current_user

      private

      # Try to read user from signed cookie; return nil if missing or invalid
      def current_user
        @current_user ||= begin
          uid = cookies.signed[:user_id]
          puts "uid=#{cookies.signed[:user_id]}"
          uid.present? ? User.find_by(id: uid) : nil
        end
      end

      # Ensure we have a user; create a guest if none and set cookie
      def ensure_user!
        return if current_user

        username = UserNameGenerator.call
        guest = User.create!(
          id: SecureRandom.uuid,
          username: username,
          email:    "#{username}@casino.com"
        )

        cookies.permanent.signed[:user_id] = {
          value: guest.id,
          httponly: false,                       # JS can read it
          same_site: :lax                        # ok for basic nav flows
        }

        @current_user = guest
      end
end
