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

  def tagname
    self.tag ? self.tag.name : ""
  end

  def Word.label
    "word"
  end

  def id_or_label
    self.id || Word.label
  end

  def suicide
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
        self.update_attributes(attrs)
        homonym.destroy
      else
        # reset added attributes
        attrs = {typo: nil, comment: nil, tag_id: nil, paradigm_id: nil}
        self.update_attributes(attrs)
      end
    else
      self.destroy
    end
  end

  # update the current word from the other word
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
    elsif eq_text
      # the word's text is the same but the word's tag changed
      # => update the tag of the current word to the new value
      puts " change the tag from #{self.tag} to #{other.tag}"  if debug
      self.tag = other.tag
      self.save
    else
      # prefer the other word
      puts " dismiss the current word and keep the other word."  if debug
      other.paradigm = self.paradigm
      self.suicide
      other.save
    end
  end
end
