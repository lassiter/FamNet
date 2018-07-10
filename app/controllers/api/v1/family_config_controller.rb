class API::V1::FamilyConfigController < ApplicationController
<<<<<<< HEAD
  # def update
  # end
  # private
  #   def config_params
  #   params.require(:family_config).permit(:authorization_enabled)
  # end
=======
  def update
  end
  private
    def config_params
    params.require(:family_config).permit(:authorization_enabled)
  end
>>>>>>> e352faff9977980e0871613fc427e68f94339c0c
end
