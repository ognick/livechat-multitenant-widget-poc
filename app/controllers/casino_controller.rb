class CasinoController < ApplicationController
    before_action :ensure_user!

    def index
      @user = current_user
    end
end
