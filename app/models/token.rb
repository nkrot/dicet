class Token < ActiveRecord::Base
  has_many :sentence_tokens
  has_many :sentences, :through => :sentence_tokens
#  has_one  :statistic

  validates :text, presence: true, uniqueness: true
  validates :upcased_text, presence: true

  def self.unknown
    where(unknown: 'true')
  end

  def self.best_for_task(max=10)
    where(unknown: 'true').order('upcased_cfnd DESC').limit(max)
  end

  def self.ranked
    order('upcased_cfnd DESC')
  end

  # options is a hash of any combination of the below keys
  #  { text:         [w1, w2, ...], 
  #    upcased_text: [w1, w2, ...],
  #    regexp:       [w1, w2, ...]}
  # instead of arrays, single value can be given
  def self.find_by_literal_or_regexp(options)
#    puts conditions.inspect
    template = []
    args = {}
    [:text, :upcased_text].each do |column|
      if options.key?(column)
        template << "tokens.#{column} IN (:#{column})"
        args[column] = [ options[column] ].flatten
      end
    end
    if options.key?(:regexp)
      options[:regexp].each do |re|
        template << "tokens.text REGEXP \'#{re}\'"
      end
    end
    template = template.join(" OR ")
    if args.empty?
      Token.where(template).distinct
    else
      Token.where(template, args).distinct
    end
  end

  def case_variants
    Token.where(upcased_text: self.upcased_text)
  end

  def compute_number_docs(column=nil)
    if column == :upcased_text
      Sentence.with_words(self.case_variants).pluck(:document_id).uniq.count
    else
      sentences.pluck(:document_id).uniq.count
    end
  end

  def compute_total_freq(column=nil)
    if column == :upcased_text
      Sentence.with_words(self.case_variants).count
    else
      sentences.count
    end
  end

  def recompute_statistics
    unless statistic
      create_statistic
    end

    values = {
      number_docs:         compute_number_docs,
      corpus_freq:         compute_total_freq,
      upcased_corpus_freq: compute_number_docs(:upcased_text),
      upcased_number_docs: compute_total_freq(:upcased_text)
    }

    values[:cfnd] = values[:number_docs]  * values[:corpus_freq] 
    values[:upcased_cfnd] = values[:upcased_number_docs] * values[:upcased_corpus_freq]

    statistic.update_attributes values
  end
end
