class User < ActiveRecord::Base
	has_many :authentications
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  def apply_omniauth(omni)
    secret = omni['credentials']['secret']
    token = omni['credentials']['token']
    authentications.build(:provider => omni['provider'],
     :uid => omni['uid'],
     :token_secret => secret,
     :token => token)
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end
end
