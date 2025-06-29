class User < ApplicationRecord
  has_many :categories
  has_many :actuals

  def self.find_or_create_from_auth_hash(auth_hash)
    provider = auth_hash[:provider]
    uid = auth_hash[:uid]

    find_or_create_by(provider: provider, uid: uid) do |user|
      user.name = auth_hash[:info][:name]
      user.email = auth_hash[:info][:email]
      user.image_url = auth_hash[:info][:image]
      user.access_token = auth_hash[:credentials][:token]
      user.refresh_token = auth_hash[:credentials][:refresh_token]
      user.expires_at = Time.at(auth_hash[:credentials][:expires_at])
    end
  end

  def refresh_access_token
    # TODO: Implement token refresh logic
  end
end
