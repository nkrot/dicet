class Token < ActiveRecord::Base
  has_many :sentence_tokens
  has_many :sentences, :through => :sentence_tokens
#  has_many :words
  belongs_to :task
#  has_one  :statistic

  validates :text, presence: true, uniqueness: true
  validates :upcased_text, presence: true

  def self.valid_casetypes
    ['al', 'au', 'tc', 'other']
  end

  def self.unknown(filters={})
#    puts "Filtering uknown words using filters: #{filters.inspect}"

    # TODO: filter by
    # "user"=>{"id"=>"2"}

    subqueries = ["tokens.unknown = 't'"]

    # casetypes
    casetypes = []
    Token.valid_casetypes.each do |ct|
      casetypes << ct  if filters.key?(ct)
    end
    
    unless casetypes.empty?
      vals = casetypes.map{|s| "\'#{s}\'"}.join(',')
      subqueries << "tokens.casetype in (#{vals})"
    end

    # by default, we dont want to see assigned tasks
    unless filters.key?('assigned')
      subqueries << "tokens.task_id in (0, '')"
    end

    # good/bad filters
    if filters.key?('good') && filters.key?('bad')
      # no sql needed
    elsif filters.key?('good')
      subqueries << "tokens.good = 't'"
    elsif filters.key?('bad')
      subqueries << "tokens.good = 'f'"
    end

    sql_query = subqueries.join(' AND ')
    puts sql_query.inspect

    where(sql_query)
  end

  def self.best_for_task(max=10)
    where("tokens.unknown = 'true' and (tokens.task_id is NULL or tokens.task_id = '')")
      .order('upcased_cfnd DESC').limit(max)
  end

  def self.ranked(col=nil)
    if !col || col.to_s.downcase == "upcased_cfnd"
      # default ranking
      order('upcased_cfnd DESC, upcased_text, cfnd DESC')
    else
      # explicit rankings
      order("#{col} DESC, upcased_text")
    end
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

  def self.case_variants(text)
    token = Token.where(text: text).first
    token ? token.case_variants : []
  end

  def dropped?
    ! taken?
  end

  def taken?
    task_id.to_i > 0
  end

  def set_bad
    tokens = case_variants
    tokens.update_all(good: false)
    tokens
  end

  def set_good
    tokens = case_variants
    tokens.update_all(good: true)
    tokens
  end

  def words
    if taken? && task # TODO: it happens (why?) that task is nil
      self.task.words
    else
      nil
    end
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
