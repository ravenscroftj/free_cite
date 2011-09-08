class User < ActiveRecord::Base  
  def self.create_account(username, password)
    self.create(:username=>username, :password=>self.hash_password(username, password))
  end  
  
  def self.hash_password(username, password)
    Digest::MD5::hexdigest([username, "Freecite", password].join(":"))    
  end
end
