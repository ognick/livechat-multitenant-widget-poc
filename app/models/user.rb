class User < ApplicationRecord
    has_many :livechat_customers, dependent: :destroy

    before_create :assign_uuid

    private

    def assign_uuid
        self.id ||= SecureRandom.uuid
    end
end
