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

    task.update(user: user)  if user

    # TODO: what if no word in Words has been linked to this task?
    # should the task from already existing word be back propagated to Tokens?
    Word.add_and_assign_to_task(all_tokens, task)

    task
  end

  def self.deassociate token
    puts "DEASSOCIATE token and its task"

    # remove the current token and its related words from the task
    # if task becomes empty, delete the task as well
    # what to do with words that were copied to Words table?

    task = token.task
#    puts "<<< Before"
#    puts task.inspect
#    puts "TOKENS in the task: #{task.tokens.inspect}"
#    puts "WORDS in the task: #{task.words.inspect}"
 
    all_tokens = token.case_variants

    Word.unlink_from_task(all_tokens)

    # unlink tokens and the task
    all_tokens.each { |tok| tok.update(task_id: 0) }

    # reget the task to see updates in tokens and words
    _task = Task.find(task.id)

#    # unlink Words from the task 
#    puts ">>> After"
#    puts _task.inspect
#    puts "TOKENS in the task: #{_task.tokens.inspect}"
#    puts "WORDS in the task: #{_task.words.inspect}"

    if _task.words.empty?
      puts "The task has become empty and will be destroyed"
      _task.destroy
    end

    all_tokens
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
