class LivechatCustomer < ApplicationRecord
  belongs_to :user

  before_create :assign_uuid

  private

  def assign_uuid
    self.id ||= SecureRandom.uuid
  end
end
