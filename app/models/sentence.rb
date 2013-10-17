class Sentence < ActiveRecord::Base
  has_many :sentence_tokens
  has_many :tokens, :through => :sentence_tokens
  belongs_to :document

  def self.with_words tokens_params
    joins(:tokens).where(:tokens => tokens_params).distinct
  end

  def self.search params
    if params[:casesensitive] == '1'
      tokens_params = {
        text: params[:word].split
      }
    else
      tokens_params = {
        upcased_text: params[:word].split.map {|w| w.mb_chars.upcase}
      }
    end
    sentences = Sentence.with_words(tokens_params)
    tokens = Token.where(tokens_params)
    return sentences, tokens
  end

  # TODO: call it from Document.add_file_data?
  def self.add_file_data(data, fname="unknown")
    infos = {
      'added_documents'    => 0,
      'added_sentences'    => 0,
      'added_new_words'    => 0, # did not previously exist in DB
      'added_total_words'  => 0  # words in sentences
    }

    c_docs = 0
    doc = Document.create(title: "#{fname}::#{c_docs}")

    data.split(/\n/).each do |line|
      line = line.chomp.strip
      next  if line.empty? || line =~ /^#/

      if line =~ /=DOC-SEPARATOR=/
        c_docs += 1
        doc = Document.create(title: "#{fname}::#{c_docs}")
        infos['added_documents'] += 1
        $stderr.puts "Adding new document: #{doc.title}"
        next
      end

      sent = Sentence.create(document: doc)
      infos['added_sentences'] += 1

      tokens = line.split
      tokens.each_with_index do |token, pos|
        tok = Token.find_or_create_by(text: token) do |tk|
          infos['added_new_words'] += 1
          tk.upcased_text = token.mb_chars.upcase.to_s
        end
        SentenceToken.create(sentence: sent, token: tok, position: pos)
      end
    end

    infos
  end

end
