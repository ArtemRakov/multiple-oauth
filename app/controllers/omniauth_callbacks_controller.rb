class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def Facebook
    p request.env['omniauth.auth']

    redirect_to rooth_path
  end
end
