class User < ActiveRecord::Base
  has_many :tasks

  has_many :new_tasks,        -> { where status: ['new', nil, ''] }, class_name: 'Task'
  has_many :ready_tasks,      -> { where status: 'ready'          }, class_name: 'Task'
  has_many :inprogress_tasks, -> { where status: 'inprogress'     }, class_name: 'Task'
  has_many :unfinished_tasks, -> { where status: ['inprogress', 'review', 'hascomment'] },
                              class_name: 'Task'

  validates :login, presence: true, length: { maximum: 50 },
                    uniqueness: { case_sensitive: false }

  VALID_EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }

#  before_save { self.email = email.downcase } #
  before_create :create_remember_token

  validates :password, presence: true;

  def User.encrypt token
    Digest::SHA1.hexdigest token.to_s
  end

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.as_options_for_select
    User.all.map {|u| [u.login, u.id]}
  end

  def authenticate password
    if self.password == password.to_s
      self
    else
      false
    end
  end

  def self.add_file_data(data)
    data.split(/\n/).each do |line|
      line = line.chomp.strip.sub(/\s+#.*$/, "")
      if line =~ /^#/ || line.empty?
        # skip
      elsif line =~ /^(.*[^\s])\s+([^\s]+@[^\s]+)\s+(.+)/
        User.create do |u|
          u.login    = $1
          u.email    = $2
          u.password = $3
        end
      end
    end
  end

  private

  def create_remember_token
    self.remember_token = User.encrypt User.new_remember_token
  end
end
