class Paradigm < ActiveRecord::Base
  STATUSES = [ "ready", "review" ]

  has_many   :words
#  has_many   :tags, :through => :paradigm_type # TODO: try this
#  validates_associated :words # TODO: what does it mean?
  belongs_to :paradigm_type
  belongs_to :task

  validates :status, inclusion: { in: STATUSES, 
    message: "%{value} is not a valid status, should be one of #{STATUSES.join(" ")}"}

  before_save :fix_empty_fields
  after_save :update_task_status

  def self.to_review
    where(status: 'review')
  end

  def self.ready
    where(status: 'ready')
  end

  def self.with_comment
    where("paradigms.comment is not NULL and paradigms.comment <> ''")
  end

  # Here we return union of:
  #  a) tags associated with the paradigm type to which the paradigm belongs
  #  b) and extra tags that were added by the user
  #
  # TODO: ensure tags are returned in the order in which they are arranged
  #       in the paradigm
  # TODO: return a Relation rather than an array. To archieve it, use find_by_sql
  #       http://stackoverflow.com/questions/6686920/activerecord-query-union
  def tags
    tags_from_words = []
    if self.id
      tags_from_words = Word.where(paradigm_id: self.id).map {|w| w.tag}
#      puts "Tag associated with the current paradigm (#{tags_from_words.length}): #{tags_from_words.inspect}"
    end

    tags_from_pdg_type = self.paradigm_type.tags
    unless tags_from_words.empty?
      # do not include NOTAG if there are other tags
      tags_from_pdg_type = tags_from_pdg_type.reject {|tag| tag.notag? }
    end

    (tags_from_pdg_type + tags_from_words).uniq
  end

  # iterates over word/tag pairs in the paradigm
  # if a tag in the paradigm was not assigned a word, returns an empty Word
  def each_word_with_tag
    tags.each do |tag|
      attrs = { paradigm_id: self.id, tag_id: tag.id }
      words = Word.where(attrs).to_a
      words << Word.new(attrs)  if words.empty?
      words.each do |word|
        yield word, tag
      end
    end
  end

  def ready_or_new?
    self.status.to_s.empty? || self.ready?
  end

  def ready?
    self.status.to_s.downcase == "ready"
  end

  def review?
    self.status.to_s.downcase == "review"
  end

  def has_comment?
    ! self.comment.to_s.empty?
  end

  def suicide
    if debug=false
      puts "Deleting #{self.inspect}"
      puts "WORDS: #{self.words.length}"
    end

    self.words.each { |word| word.suicide }
    self.destroy
  end

  def has_word_or_homonym_of? word
    self.words.any? {|wd| ! Word.where(text: word.text).empty? }
  end

  def has_word_linked_to_task? task
    self.words.all? {|word| Word.where(text: word.text, task: task).empty?}
  end

  # not used yet
#  def dumped?
#    self.status.to_s.downcase == "dumped"
#  end

  def update_task_status
    puts "Recomputing task status of the task #{task.inspect}"
    if task # ideally this should not happen but...
      new_status = if task.paradigms.empty?
                     'new'
                   elsif ! task.paradigms.to_review.empty?
                     'review'
                   elsif ! task.paradigms.with_comment.empty?
                     'hascomment'
                   elsif ! task.paradigms.ready.empty?
                     # TODO: bad! need to check that all words have been done
                     'ready'
                   else
                     'inprogress'
                   end
      task.update_attributes(status: new_status)
      puts "new value of task.status=#{task.status}"
    end
  end

  private

  #http://stackoverflow.com/questions/7202319/rails-force-empty-string-to-null-in-the-database
  def fix_empty_fields
    if self.comment.instance_of?(String) && self.comment =~ /^\s*$/
      self.comment = nil
    end
  end
end
