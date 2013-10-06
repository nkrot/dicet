class Word < ActiveRecord::Base
  belongs_to :paradigm
  belongs_to :task
  belongs_to :tag

  validates :text, presence: true, length: { maximum: 400 }
  # uniqueness: true -- word can legally repeat several times if
  #  it has different tags and/or belongs to several paradigms

#  def all_paradigm_ids
#    Word.where(text: self.text).map(&:paradigm_id) #=> Relation
#  end

  def homonyms
    Word.where(text: self.text).sort_by(&:paradigm_id)
  end

  def has_paradigms_to_review?
    self.paradigm && Word.where(text: self.text).any? {|w| w.paradigm.review? }
  end

  def has_paradigms_with_comment?
    self.paradigm && Word.where(text: self.text).any? {|w| w.paradigm.has_comment? }
  end

  def tagname
    self.tag ? self.tag.name : ""
  end

  def Word.label
    "word"
  end

  def same? other
    return false  unless other
    self.id == other.id
  end

  def id_or_label
    self.id || Word.label
  end

  def empty?
    self.text.to_s.empty?
  end

  def nonempty?
    ! self.empty?
  end

  def suicide
    debug = false
    puts "<<< in #{self.class}#suicide >>> " if debug
    if self.task_id
      # find an added word and make it replace the original word
      # that we intent to delete.
      # Scenario that shows the situation:
      #  1) add paradigm word_NN => original word will be added NN and pdg_id=1
      #  2) add paradigm word_VB => added will be word_VB and pdg_id=2
      #  3) delete paradigm pdg_id=1 with word_NN. we now want original word contain word_VB and point to pdg_id=2 
      homonym = Word.where(text: self.text, task_id: nil).where.not(tag_id: nil, id: self.id, paradigm_id: self.paradigm_id).first
#      puts "Homonym: #{homonym.inspect}"

      if homonym
        # copy added attributes from the homonym
        attrs = {
          typo:        homonym.typo,
          comment:     homonym.comment,
          tag_id:      homonym.tag_id,
          paradigm_id: homonym.paradigm_id
        }
        puts "#{self.inspect} will be switched to its homonym"  if debug
        self.update_attributes(attrs)
        homonym.destroy

      else
        # reset added attributes
        puts "#{self.inspect} is going to get its added attributes reset"  if debug
        attrs = {typo: nil, comment: nil, tag: nil, paradigm: nil}
        self.update_attributes(attrs)
        puts "Reset to #{self.inspect}"  if debug
      end

    else
      puts "#{self.inspect} is going to be destroyed"  if debug
      self.destroy
    end
  end

  # update the current word from the other word and return
  # the updated object, that is either updated self or other
  #
  # NOTE: this method should be used like this:
  #   wd = wd.update_from(other)
  # because we can not replace self with another object
  #
  # TODO: other fields (typo, comment) not handled yet

  def update_from other
    debug = false
    puts "update_from: current is #{self.inspect}; the other is #{other.inspect}" if debug

    # compare fields
    eq_text = self.text == other.text
    eq_tag  = self.tag  == other.tag

    if eq_text && eq_tag
      # the word's text and tag have not changed
      # => just keep the current word and throw away the other word
      puts " keep the current word"  if debug
      self

    elsif eq_text
      # the word's text is the same but the word's tag changed
      # => update the tag of the current word to the new value
      puts " change the tag from #{self.tag} to #{other.tag}"  if debug
      self.tag = other.tag
      self.save
      self

    else
      # prefer the other word
      # TODO: need to set self=other
      puts " dismiss the current word and keep the other word."  if debug
      other.paradigm = self.paradigm
      other.save
      self.suicide
      other
    end
  end

  def self.add_file_data(data)
    tasksize = Task::NUMWORDS
    priority = Task::PRIORITY

    task = nil

    infos = {
      'number_of_tasks' => 0,
      'number_of_words' => 0,
      'rejected_lines'  => []
    }

    data.split(/\n/).each do |line|
      line.chomp!
      case line
      when line.empty?
        # skip
      when /^#/
        # skip comments
      when /^tasksize=(\d+)/i
        tasksize = $1.to_i
      when /^priority=(\d+)/i
        priority = $1.to_i
      else
        # word \t priority
        word, prty = line.sub(/\s#.+/, "").split
        prty = prty ? prty.to_i : priority

        if Word.exists?(text: word)
          infos['rejected_lines'] << line
        else
          unless task
            task = Task.create(priority: prty)
          end

          task.words.create(text: word)
          infos ['number_of_words'] += 1

          if task.words.count >= tasksize
            task.save
            task = nil
            infos ['number_of_tasks'] += 1
          end
        end
      end
    end

    infos
  end

end
