class Task < ActiveRecord::Base
  belongs_to :user
  has_many :words
  has_many :paradigms

  # valid statuses
  # new, ready, inprogress
  # review  -- if the task has a paradigm marked to review
  # hascomment -- if the task has a paradigm having a comment

  # defaults
  NUMWORDS = 5 # default size of the task - number of words in the task
  PRIORITY = 9

  before_save :fix_status

  def self.unassigned
    where(user_id: nil)
  end

  def self.assigned_to(user)
    where(user: user)
  end

  def new?
    status.to_s.empty? || status == 'new'
  end

  private

  def fix_status
    if self.status.to_s.empty?
      self.status = 'new'
    else
      self.status = self.status.downcase
    end
  end

end
