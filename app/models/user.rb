class User < ApplicationRecord
  def self.find_or_create_from_auth_hash(auth_hash)
    provider = auth_hash[:provider]
    uid = auth_hash[:uid]

    find_or_create_by(provider: provider, uid: uid) do |user|
      user.name = auth_hash[:info][:name]
      user.email = auth_hash[:info][:email]
      user.image_url = auth_hash[:info][:image]
    end
  end
end
