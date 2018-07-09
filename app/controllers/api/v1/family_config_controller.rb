class API::V1::FamilyConfigController < ApplicationController
  def update
  end
  private
    def config_params
    params.require(:family_config).permit(:authorization_enabled)
  end
end
