class Task < ActiveRecord::Base
  belongs_to :user
  has_many :words
  has_many :paradigms
  has_many :tokens

  scope :today,        -> { where "DATE(updated_at) = ?",  Date.today.to_s(:db) }
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

  # TODO: get rid of it
#  def self.generate(quantity=10)
##    puts "==== generating new tasks ===="
#    tokens = Token.best_for_task(quantity)
#
#    # ensure all case variants are present in the task
#    tokens.last.case_variants.each do |t|
#      unless tokens.include? t
#        tokens << t
#      end
#    end
#
##    # remove extra tokens if there are too many for a task
##    if tokens.length > quantity*2
##    end
#
##    puts "Number of words for the new task: #{tokens.length}"
##    puts tokens.inspect
#
#    if tokens.empty?
#      puts 'Oops. Something went wrong, no tokens selected for the new task'
#      return false
#    end
#
#    task = Task.create(priority: PRIORITY)
#
#    Word.add_and_assign_to_task(tokens, task)
#
#    task
#  end

  def self.create_with_tokens(tokens, user=nil)
    puts "*** Creating task from the following #{tokens.length} tokens:\n#{tokens.inspect}"
    puts "*** The task will be assigned to #{user.inspect}"

    all_tokens = tokens.map {|token| token.case_variants }.flatten
    puts "All case variants (#{all_tokens.length} items):\n#{all_tokens.inspect}"

    task = Task.create(priority: PRIORITY)

    if user
      task.user = user
      task.save
    end

    Word.add_and_assign_to_task(all_tokens, task)

    task
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
