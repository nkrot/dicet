class Task < ActiveRecord::Base
  belongs_to :user
  has_many :words
  has_many :paradigms

  scope :today,        -> { where "DATE(updated_at) = ?",  Date.today }
  scope :during_week,  -> { where "DATE(updated_at) >= DATE(?)", 1.week.ago }
  scope :during_month, -> { where "DATE(updated_at) >= DATE(?)", 1.month.ago }
  scope :except_ready, -> { where "status <> ?", 'ready' }

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

  def self.ready
    where(status: 'ready')
  end

  def new?
    status.to_s.empty? || status == 'new'
  end

  def has_new_words?
    ! words.where(paradigm_id: nil).empty?
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
