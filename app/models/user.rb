class User < ActiveRecord::Base
  has_many :tasks

  validates :login, presence: true, length: { maximum: 50 },
                    uniqueness: { case_sensitive: false }

  VALID_EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }

#  before_save { self.email = email.downcase } #
  before_create :create_remember_token

  validates :password, presence: true

  def User.encrypt token
    Digest::SHA1.hexdigest token.to_s
  end

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def authenticate password
    if self.password == password.to_s
      self
    else
      false
    end
  end

  private

  def create_remember_token
    self.remember_token = User.encrypt User.new_remember_token
  end
end
