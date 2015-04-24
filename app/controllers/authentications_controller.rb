class AuthenticationsController < ApplicationController
  before_action :set_authentication, only: [:show, :edit, :update, :destroy]

  respond_to :html
  def home
    @authentications = Authentication.all
  end

  def my_posts
    if !current_user.authentications.nil?
      if !current_user.authentications.find_by_provider('facebook').nil?
        fb_info = Authentication.find_by_provider('facebook')
        @fb_feed = Authentication.get_feed(fb_info)
        # puts "===================="
        # puts @fb_feed.to_json
        # puts "===================="
      end
      if !current_user.authentications.find_by_provider('twitter').nil?
        twit_info = Authentication.find_by_provider('twitter')
        @twit_feed = Authentication.get_tweets(twit_info)
        # puts "===================="
        # puts @twit_feed.to_json
        # puts "===================="
      end
      if !current_user.authentications.find_by_provider('google_oauth2').nil?
        gplus_info = Authentication.find_by_provider('google_oauth2')
        puts "===================="
        puts gplus_info.to_json
        puts "===================="
        @gplus_feed = Authentication.get_gplus_feed(gplus_info)
        puts "===================="
        puts @gplus_feed.to_json
        puts "===================="
      end
    end
  end
  
  def twitter
    omni = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omni['provider'], omni['uid'])
    if authentication
      flash[:notice] = "Logged in Successfully"
      sign_in_and_redirect User.find(authentication.user_id)
    elsif current_user
      token = omni['credentials'].token
      token_secret = omni['credentials'].secret
      current_user.authentications.create!(:provider => omni['provider'], :uid => omni['uid'], :token => token, :token_secret => token_secret)
      flash[:notice] = "Authentication successful."
      sign_in_and_redirect current_user
    else
      twitter_nickname = omni['info']['nickname']
      user = User.new(:email =>"#{twitter_nickname}@example.org")
      user.apply_omniauth(omni)
      if user.save
        flash[:notice] = "Logged in."
        sign_in_and_redirect User.find(user.id)
      else
        session[:omniauth] = omni.except('extra')
        redirect_to new_user_registration_path
      end
    end
  end  

  def facebook
    omni = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omni['provider'], omni['uid'])
    if authentication
      flash[:notice] = "Logged in Successfully"
      sign_in_and_redirect User.find(authentication.user_id)
    elsif current_user
      token = omni['credentials'].token
      token_secret = omni['credentials'].secret
      current_user.authentications.create!(:provider => omni['provider'], :uid => omni['uid'], :token => token, :token_secret => token_secret)
      flash[:notice] = "Authentication successful."
      sign_in_and_redirect current_user
    else
      user = User.new(:email => omni['extra']['raw_info']['email'])
      user.apply_omniauth(omni)
      if user.save
        flash[:notice] = "Logged in."
        sign_in_and_redirect User.find(user.id)
      else
        session[:omniauth] = omni.except('extra')
        redirect_to new_user_registration_path
      end
    end
  end

  def google_oauth2
    omni = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omni['provider'], omni['uid'])
    if authentication
      flash[:notice] = "Logged in Successfully"
      sign_in_and_redirect User.find(authentication.user_id)
    elsif current_user
      token = omni['credentials'].token
      token_secret = omni['credentials'].secret
      current_user.authentications.create!(:provider => omni['provider'], :uid => omni['uid'], :token => token, :token_secret => token_secret)
      flash[:notice] = "Authentication successful."
      sign_in_and_redirect current_user
    else
      user = User.new(:email => omni['extra']['raw_info']['email'])
      user.apply_omniauth(omni)
      if user.save
        flash[:notice] = "Logged in."
        sign_in_and_redirect User.find(user.id)
      else
        session[:omniauth] = omni.except('extra')
        redirect_to new_user_registration_path
      end
    end
  end

  # Warden::Manager.before_logout do |user,auth,opts|
  #   # store what ever you want on logout
  #   # If not in initializer it will generate two records (strange)
  #   @authentication = Authentication.find_by_user_id(current_user.id)
  #   @authentication.destroy  
  # end

  def create
    raise request.env["omniauth.auth"].to_yaml
    @authentication = Authentication.new(params[:authentication])
    if @authentication.save
      redirect_to authentications_url, :notice => "Successfully created authentication."
    else
      render :action => 'new'
    end
  end

  def destroy
    @authentication = Authentication.find(params[:id])
    @authentication.destroy
    redirect_to home_path, :notice => "Successfully destroyed authentication."
  end

  private
    def set_authentication
      @authentication = Authentication.find(params[:id])
    end

    def authentication_params
      params.require(:authentication).permit(:user_id, :provider, :uid, :token, :token_secret)
    end
end
