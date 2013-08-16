class User < ActiveRecord::Base
  #has_many: tasks

  validates :login, presence: true, length: { maximum: 50 },
                    uniqueness: { case_sensitive: false }

  VALID_EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }

#  before_save { self.email = email.downcase } #

  validates :password, presence: true

  def authenticate password
    if self.password == password.to_s
      self
    else
      false
    end
  end
end
