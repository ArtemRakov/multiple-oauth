class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :set_service
  before_action :set_user
  attr_reader :service, :user

  def facebook
    handle_auth "facebook"
  end

  def twitter
    handle_auth "twitter"
  end

  private

  def handle_auth(kind)
    if service.present?
      service.update(service_attrs)
    else
      user.services.create(service_attrs)
    end

    if user_signed_in?
      flash[:notice] = "Your #{kind} account was connected"
      redirect_to edit_user_registration_path
    else
      sign_in_and_redirect user, event: :authetication
      set_flash_message :notice, :success, kind: kind
    end
  end

  def auth
    request.env['omniauth.auth']
  end

  def set_service
    @service = Service.where(provider: auth.provider, uid: auth.uid).first
  end

  def set_user
    if user_signed_in?
      @user = current_user
    elsif service.present?
      @user = service.user
    elsif User.where(email: auth.info.email).any?
        flash[:alert] = "An account with this email already exist. Please sign in with this account before connecting your #{auth.provider.titleize} account"
        redirect_to new_user_session_path
    else
      @user = User.create(create_user)
    end
  end

  def service_attrs
    expires_at = auth.credentials.expires_at.present? ? Time.at(auth.credentials.expires_at) : nil
    {
      provider: auth.provider,
      uid: auth.uid,
      expires_at: expires_at,
      access_token: auth.credentials.token
    }
  end

  def create_user
    {
      email: auth.info.email,
      password: Devise.friendly_token[0, 20]
    }
  end
end
