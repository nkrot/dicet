class Token < ActiveRecord::Base
  has_many :sentence_tokens
  has_many :sentences, :through => :sentence_tokens

  validates :text, presence: true, uniqueness: true
  validates :upcased_text, presence: true

  # options is a hash of any combination of the below keys
  #  { text:         [w1, w2, ...], 
  #    upcased_text: [w1, w2, ...],
  #    regexp:       [w1, w2, ...]}
  # instead of arrays, single value can be given
  def self.find_by_literal_or_regexp(options)
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
        template << "tokens.text REGEXP \"#{re}\""
      end
    end
    template = template.join(" OR ")
    Token.where(template, args).distinct
  end
end
