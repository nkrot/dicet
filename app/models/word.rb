class Word < ActiveRecord::Base
  belongs_to :paradigm
  belongs_to :task

  validates :text, presence: true, length: { maximum: 400 }
  # uniqueness: true -- word can legally repeat several times if
  #  it has different tags and/or belongs to several paradigms

  def all_paradigm_ids
    Word.where(text: self.text).map(&:paradigm_id)
  end

  def homonyms
    Word.where(text: self.text).sort_by(&:paradigm_id)
  end
end
